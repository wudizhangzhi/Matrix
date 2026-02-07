# Matrix Terminal - 设计文档

## 概述

Matrix Terminal 是一个使用 Flutter 开发的跨平台 SSH 客户端，优先支持 Android。核心目标：提供与 Termius 一致的 UI 体验，同时彻底解决 Android 端中文输入问题。

## 技术栈

| 类别 | 选型 | 说明 |
|------|------|------|
| 框架 | Flutter | 跨平台，Android 优先 |
| SSH 协议 | dartssh2 | 纯 Dart 实现，无原生依赖 |
| 终端渲染 | xterm | Flutter 原生终端组件 |
| 状态管理 | Riverpod | 类型安全，适合多会话管理 |
| 本地数据库 | Isar | 高性能 NoSQL |
| 敏感存储 | flutter_secure_storage | 密码/密钥加密存储 |
| TOTP | otp | 多因素认证 |
| 后台保活 | flutter_background_service | 前台服务 |
| WakeLock | wakelock_plus | 防止 CPU 休眠 |

## 项目结构

```
lib/
├── app/                        # 应用入口、路由、主题
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── features/
│   ├── host/                   # 主机管理（增删改查、分组）
│   │   ├── models/
│   │   │   ├── host.dart
│   │   │   └── host_group.dart
│   │   ├── screens/
│   │   │   ├── host_list_screen.dart
│   │   │   └── host_edit_screen.dart
│   │   ├── widgets/
│   │   │   ├── host_card.dart
│   │   │   └── group_section.dart
│   │   └── providers/
│   │       └── host_provider.dart
│   ├── terminal/               # 终端会话
│   │   ├── models/
│   │   │   └── session.dart
│   │   ├── screens/
│   │   │   └── terminal_screen.dart
│   │   ├── widgets/
│   │   │   ├── terminal_view.dart
│   │   │   ├── tab_bar.dart
│   │   │   ├── toolbar.dart
│   │   │   └── input_bar.dart
│   │   └── providers/
│   │       └── session_provider.dart
│   └── settings/               # 设置
│       ├── screens/
│       │   ├── settings_screen.dart
│       │   └── key_manage_screen.dart
│       └── providers/
│           └── settings_provider.dart
├── core/
│   ├── ssh/
│   │   ├── ssh_service.dart    # dartssh2 封装
│   │   └── auth_handler.dart   # 认证处理
│   ├── storage/
│   │   ├── database.dart       # Isar 初始化
│   │   └── secure_store.dart   # flutter_secure_storage 封装
│   ├── background/
│   │   └── background_service.dart  # 后台保活
│   └── utils/
│       └── constants.dart
└── main.dart
```

## 数据模型

### Host（主机）

```dart
class Host {
  String id;              // UUID
  String label;           // 显示名称
  String hostname;        // IP 或域名
  int port;               // 默认 22
  String username;
  String? groupId;        // 所属分组
  AuthType authType;      // password / privateKey / totp
  String? passwordRef;    // 指向 secure_storage 的 key
  String? privateKeyRef;
  String? totpSecret;
  int sortOrder;
  DateTime createdAt;
  DateTime lastConnectedAt;
}

enum AuthType { password, privateKey, totp }
```

### HostGroup（分组）

```dart
class HostGroup {
  String id;
  String name;
  int sortOrder;
  IconData? icon;
}
```

### Session（会话）

```dart
class Session {
  String id;
  String hostId;
  SSHClient? client;
  Terminal? terminal;
  SessionState state;     // connecting / connected / disconnected / error
  DateTime connectedAt;
}

enum SessionState { connecting, connected, disconnected, error }
```

### 安全存储策略

- Host 基本信息存在 Isar（不含密码明文）
- 密码和私钥通过 flutter_secure_storage 加密存储，Host 中只保存引用 key
- TOTP secret 同样加密存储

## UI 设计规范（对标 Termius）

### 配色方案（深色主题）

```
背景色：        #0B133B（深蓝黑）
卡片/列表背景： #151E3F（稍浅深蓝）
主强调色：      #6C63FF（紫蓝色）
文字主色：      #E8ECF4（浅灰白）
文字次要色：    #8890A6（灰色）
成功/在线：     #4CAF50（绿色）
错误/断开：     #FF5252（红色）
分隔线：        #1E2A5E
```

### 主机列表页

- 顶部搜索栏 + 右上角 "+" 添加按钮
- 分组以可折叠的 section header 展示（带图标 + 主机数量）
- 每个主机条目：左侧圆形图标（首字母）、主机名称、地址副标题、右侧连接状态小圆点
- 长按弹出编辑/删除/复制菜单
- 底部导航栏：Hosts | Keychain | Settings

### 终端页

- 顶部标签栏：水平滚动标签页，每个标签显示主机名，"+" 号新建会话
- 中部终端区域：等宽字体，深色背景
- 终端上方浮动工具栏：Ctrl、Alt、Tab、Esc、方向键
- 底部独立输入栏：支持中文 IME 的 TextField + 发送按钮

## 核心逻辑

### SSH 连接生命周期

```
用户点击主机 → 创建 Session → SSHClient.connect()
  ├── 认证（密码/密钥/TOTP）
  ├── 成功 → 打开 Shell Channel → 绑定 xterm Terminal
  └── 失败 → 显示错误 → 提供重试选项

连接中：
  ├── 输入框文字 → channel.write() → 远程服务器
  ├── channel.stdout → terminal.write() → 屏幕渲染
  └── 心跳保活（每 15s 发送 keepalive）

断开：
  ├── 用户主动关闭标签
  ├── 网络中断 → 自动重连（最多 3 次，间隔递增）
  └── 服务器断开 → 提示用户，保留终端输出可查看
```

### 中文输入处理（核心创新点）

```
Flutter TextField (IME composing)
  → 用户完成拼音输入，确认中文文字
  → onSubmitted 回调
  → utf8.encode(text)
  → channel.write(encodedBytes)
  → 远程服务器回显
  → channel.stdout 读取
  → terminal.write() 渲染到屏幕
```

不拦截 composing 阶段，只在用户确认输入后才发送，避免拼音中间态被发送到服务器。

### 多会话管理

```dart
class SessionManager {
  List<Session> sessions;
  int activeIndex;

  Future<Session> connect(Host host);
  void switchTo(int index);
  void close(int index);
}
```

每个 Session 持有独立的 SSHClient 和 Terminal 实例，标签切换只是切换显示哪个 Terminal widget。

### 后台保活策略

```
前台服务 (Foreground Service)
  ├── 启动时机：第一个 SSH 会话建立时启动
  ├── 常驻通知：显示 "Matrix Terminal - N 个活跃连接"
  ├── 停止时机：所有会话关闭后自动停止
  └── 优先级：PRIORITY_LOW

保活三层保障：
  1. Foreground Service — 防止系统回收进程
  2. SSH Keepalive — 每 15s 心跳包，防止服务器/NAT 超时
  3. WakeLock (partial) — 防止 CPU 休眠导致网络中断
```

首次启动引导用户关闭电池优化，适配国产厂商系统。

## 功能范围

### MVP（第一版）

- [x] 主机管理：增删改查
- [x] 分组管理：创建分组、拖拽排序
- [x] SSH 连接：密码认证
- [x] 终端渲染：xterm.dart
- [x] 中文输入：独立输入栏
- [x] 多标签会话
- [x] 后台保活
- [x] 深色主题（对标 Termius）

### 第二版

- [ ] SSH 密钥认证（生成/导入）
- [ ] TOTP 多因素认证
- [ ] 终端配色自定义
- [ ] 字体大小调整
- [ ] 自动重连

### 未来

- [ ] iOS 支持
- [ ] SFTP 文件管理
- [ ] 端口转发
- [ ] 片段（Snippets）管理
