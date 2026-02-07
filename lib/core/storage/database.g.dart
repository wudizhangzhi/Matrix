// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HostGroupsTable extends HostGroups
    with TableInfo<$HostGroupsTable, HostGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HostGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'host_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<HostGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HostGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HostGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $HostGroupsTable createAlias(String alias) {
    return $HostGroupsTable(attachedDatabase, alias);
  }
}

class HostGroup extends DataClass implements Insertable<HostGroup> {
  final String id;
  final String name;
  final int sortOrder;
  final String? icon;
  const HostGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  HostGroupsCompanion toCompanion(bool nullToAbsent) {
    return HostGroupsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory HostGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HostGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  HostGroup copyWith({
    String? id,
    String? name,
    int? sortOrder,
    Value<String?> icon = const Value.absent(),
  }) => HostGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    icon: icon.present ? icon.value : this.icon,
  );
  HostGroup copyWithCompanion(HostGroupsCompanion data) {
    return HostGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HostGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HostGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.icon == this.icon);
}

class HostGroupsCompanion extends UpdateCompanion<HostGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String?> icon;
  final Value<int> rowid;
  const HostGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostGroupsCompanion.insert({
    required String id,
    required String name,
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<HostGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return HostGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HostsTable extends Hosts with TableInfo<$HostsTable, Host> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostnameMeta = const VerificationMeta(
    'hostname',
  );
  @override
  late final GeneratedColumn<String> hostname = GeneratedColumn<String>(
    'hostname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES host_groups (id)',
    ),
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('password'),
  );
  static const VerificationMeta _passwordRefMeta = const VerificationMeta(
    'passwordRef',
  );
  @override
  late final GeneratedColumn<String> passwordRef = GeneratedColumn<String>(
    'password_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _privateKeyRefMeta = const VerificationMeta(
    'privateKeyRef',
  );
  @override
  late final GeneratedColumn<String> privateKeyRef = GeneratedColumn<String>(
    'private_key_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totpSecretRefMeta = const VerificationMeta(
    'totpSecretRef',
  );
  @override
  late final GeneratedColumn<String> totpSecretRef = GeneratedColumn<String>(
    'totp_secret_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    hostname,
    port,
    username,
    groupId,
    authType,
    passwordRef,
    privateKeyRef,
    totpSecretRef,
    sortOrder,
    createdAt,
    lastConnectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hosts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Host> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('hostname')) {
      context.handle(
        _hostnameMeta,
        hostname.isAcceptableOrUnknown(data['hostname']!, _hostnameMeta),
      );
    } else if (isInserting) {
      context.missing(_hostnameMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('password_ref')) {
      context.handle(
        _passwordRefMeta,
        passwordRef.isAcceptableOrUnknown(
          data['password_ref']!,
          _passwordRefMeta,
        ),
      );
    }
    if (data.containsKey('private_key_ref')) {
      context.handle(
        _privateKeyRefMeta,
        privateKeyRef.isAcceptableOrUnknown(
          data['private_key_ref']!,
          _privateKeyRefMeta,
        ),
      );
    }
    if (data.containsKey('totp_secret_ref')) {
      context.handle(
        _totpSecretRefMeta,
        totpSecretRef.isAcceptableOrUnknown(
          data['totp_secret_ref']!,
          _totpSecretRefMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Host map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Host(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      hostname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hostname'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      )!,
      passwordRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_ref'],
      ),
      privateKeyRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_key_ref'],
      ),
      totpSecretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}totp_secret_ref'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
    );
  }

  @override
  $HostsTable createAlias(String alias) {
    return $HostsTable(attachedDatabase, alias);
  }
}

class Host extends DataClass implements Insertable<Host> {
  final String id;
  final String label;
  final String hostname;
  final int port;
  final String username;
  final String? groupId;
  final String authType;
  final String? passwordRef;
  final String? privateKeyRef;
  final String? totpSecretRef;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? lastConnectedAt;
  const Host({
    required this.id,
    required this.label,
    required this.hostname,
    required this.port,
    required this.username,
    this.groupId,
    required this.authType,
    this.passwordRef,
    this.privateKeyRef,
    this.totpSecretRef,
    required this.sortOrder,
    required this.createdAt,
    this.lastConnectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['hostname'] = Variable<String>(hostname);
    map['port'] = Variable<int>(port);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['auth_type'] = Variable<String>(authType);
    if (!nullToAbsent || passwordRef != null) {
      map['password_ref'] = Variable<String>(passwordRef);
    }
    if (!nullToAbsent || privateKeyRef != null) {
      map['private_key_ref'] = Variable<String>(privateKeyRef);
    }
    if (!nullToAbsent || totpSecretRef != null) {
      map['totp_secret_ref'] = Variable<String>(totpSecretRef);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    return map;
  }

  HostsCompanion toCompanion(bool nullToAbsent) {
    return HostsCompanion(
      id: Value(id),
      label: Value(label),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      authType: Value(authType),
      passwordRef: passwordRef == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordRef),
      privateKeyRef: privateKeyRef == null && nullToAbsent
          ? const Value.absent()
          : Value(privateKeyRef),
      totpSecretRef: totpSecretRef == null && nullToAbsent
          ? const Value.absent()
          : Value(totpSecretRef),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
    );
  }

  factory Host.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Host(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      hostname: serializer.fromJson<String>(json['hostname']),
      port: serializer.fromJson<int>(json['port']),
      username: serializer.fromJson<String>(json['username']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      authType: serializer.fromJson<String>(json['authType']),
      passwordRef: serializer.fromJson<String?>(json['passwordRef']),
      privateKeyRef: serializer.fromJson<String?>(json['privateKeyRef']),
      totpSecretRef: serializer.fromJson<String?>(json['totpSecretRef']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'hostname': serializer.toJson<String>(hostname),
      'port': serializer.toJson<int>(port),
      'username': serializer.toJson<String>(username),
      'groupId': serializer.toJson<String?>(groupId),
      'authType': serializer.toJson<String>(authType),
      'passwordRef': serializer.toJson<String?>(passwordRef),
      'privateKeyRef': serializer.toJson<String?>(privateKeyRef),
      'totpSecretRef': serializer.toJson<String?>(totpSecretRef),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
    };
  }

  Host copyWith({
    String? id,
    String? label,
    String? hostname,
    int? port,
    String? username,
    Value<String?> groupId = const Value.absent(),
    String? authType,
    Value<String?> passwordRef = const Value.absent(),
    Value<String?> privateKeyRef = const Value.absent(),
    Value<String?> totpSecretRef = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
  }) => Host(
    id: id ?? this.id,
    label: label ?? this.label,
    hostname: hostname ?? this.hostname,
    port: port ?? this.port,
    username: username ?? this.username,
    groupId: groupId.present ? groupId.value : this.groupId,
    authType: authType ?? this.authType,
    passwordRef: passwordRef.present ? passwordRef.value : this.passwordRef,
    privateKeyRef: privateKeyRef.present
        ? privateKeyRef.value
        : this.privateKeyRef,
    totpSecretRef: totpSecretRef.present
        ? totpSecretRef.value
        : this.totpSecretRef,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
  );
  Host copyWithCompanion(HostsCompanion data) {
    return Host(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      hostname: data.hostname.present ? data.hostname.value : this.hostname,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      authType: data.authType.present ? data.authType.value : this.authType,
      passwordRef: data.passwordRef.present
          ? data.passwordRef.value
          : this.passwordRef,
      privateKeyRef: data.privateKeyRef.present
          ? data.privateKeyRef.value
          : this.privateKeyRef,
      totpSecretRef: data.totpSecretRef.present
          ? data.totpSecretRef.value
          : this.totpSecretRef,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Host(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('groupId: $groupId, ')
          ..write('authType: $authType, ')
          ..write('passwordRef: $passwordRef, ')
          ..write('privateKeyRef: $privateKeyRef, ')
          ..write('totpSecretRef: $totpSecretRef, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastConnectedAt: $lastConnectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    hostname,
    port,
    username,
    groupId,
    authType,
    passwordRef,
    privateKeyRef,
    totpSecretRef,
    sortOrder,
    createdAt,
    lastConnectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Host &&
          other.id == this.id &&
          other.label == this.label &&
          other.hostname == this.hostname &&
          other.port == this.port &&
          other.username == this.username &&
          other.groupId == this.groupId &&
          other.authType == this.authType &&
          other.passwordRef == this.passwordRef &&
          other.privateKeyRef == this.privateKeyRef &&
          other.totpSecretRef == this.totpSecretRef &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastConnectedAt == this.lastConnectedAt);
}

class HostsCompanion extends UpdateCompanion<Host> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> hostname;
  final Value<int> port;
  final Value<String> username;
  final Value<String?> groupId;
  final Value<String> authType;
  final Value<String?> passwordRef;
  final Value<String?> privateKeyRef;
  final Value<String?> totpSecretRef;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastConnectedAt;
  final Value<int> rowid;
  const HostsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.hostname = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.groupId = const Value.absent(),
    this.authType = const Value.absent(),
    this.passwordRef = const Value.absent(),
    this.privateKeyRef = const Value.absent(),
    this.totpSecretRef = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostsCompanion.insert({
    required String id,
    required String label,
    required String hostname,
    this.port = const Value.absent(),
    required String username,
    this.groupId = const Value.absent(),
    this.authType = const Value.absent(),
    this.passwordRef = const Value.absent(),
    this.privateKeyRef = const Value.absent(),
    this.totpSecretRef = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       hostname = Value(hostname),
       username = Value(username);
  static Insertable<Host> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? hostname,
    Expression<int>? port,
    Expression<String>? username,
    Expression<String>? groupId,
    Expression<String>? authType,
    Expression<String>? passwordRef,
    Expression<String>? privateKeyRef,
    Expression<String>? totpSecretRef,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastConnectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (hostname != null) 'hostname': hostname,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (groupId != null) 'group_id': groupId,
      if (authType != null) 'auth_type': authType,
      if (passwordRef != null) 'password_ref': passwordRef,
      if (privateKeyRef != null) 'private_key_ref': privateKeyRef,
      if (totpSecretRef != null) 'totp_secret_ref': totpSecretRef,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? hostname,
    Value<int>? port,
    Value<String>? username,
    Value<String?>? groupId,
    Value<String>? authType,
    Value<String?>? passwordRef,
    Value<String?>? privateKeyRef,
    Value<String?>? totpSecretRef,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastConnectedAt,
    Value<int>? rowid,
  }) {
    return HostsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      groupId: groupId ?? this.groupId,
      authType: authType ?? this.authType,
      passwordRef: passwordRef ?? this.passwordRef,
      privateKeyRef: privateKeyRef ?? this.privateKeyRef,
      totpSecretRef: totpSecretRef ?? this.totpSecretRef,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (hostname.present) {
      map['hostname'] = Variable<String>(hostname.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (passwordRef.present) {
      map['password_ref'] = Variable<String>(passwordRef.value);
    }
    if (privateKeyRef.present) {
      map['private_key_ref'] = Variable<String>(privateKeyRef.value);
    }
    if (totpSecretRef.present) {
      map['totp_secret_ref'] = Variable<String>(totpSecretRef.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('groupId: $groupId, ')
          ..write('authType: $authType, ')
          ..write('passwordRef: $passwordRef, ')
          ..write('privateKeyRef: $privateKeyRef, ')
          ..write('totpSecretRef: $totpSecretRef, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToolbarProfilesTable extends ToolbarProfiles
    with TableInfo<$ToolbarProfilesTable, ToolbarProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToolbarProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buttonsMeta = const VerificationMeta(
    'buttons',
  );
  @override
  late final GeneratedColumn<String> buttons = GeneratedColumn<String>(
    'buttons',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isBuiltIn, buttons];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'toolbar_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ToolbarProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('buttons')) {
      context.handle(
        _buttonsMeta,
        buttons.isAcceptableOrUnknown(data['buttons']!, _buttonsMeta),
      );
    } else if (isInserting) {
      context.missing(_buttonsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ToolbarProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToolbarProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      buttons: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buttons'],
      )!,
    );
  }

  @override
  $ToolbarProfilesTable createAlias(String alias) {
    return $ToolbarProfilesTable(attachedDatabase, alias);
  }
}

class ToolbarProfile extends DataClass implements Insertable<ToolbarProfile> {
  final int id;
  final String name;
  final bool isBuiltIn;
  final String buttons;
  const ToolbarProfile({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.buttons,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['buttons'] = Variable<String>(buttons);
    return map;
  }

  ToolbarProfilesCompanion toCompanion(bool nullToAbsent) {
    return ToolbarProfilesCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
      buttons: Value(buttons),
    );
  }

  factory ToolbarProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToolbarProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      buttons: serializer.fromJson<String>(json['buttons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'buttons': serializer.toJson<String>(buttons),
    };
  }

  ToolbarProfile copyWith({
    int? id,
    String? name,
    bool? isBuiltIn,
    String? buttons,
  }) => ToolbarProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    buttons: buttons ?? this.buttons,
  );
  ToolbarProfile copyWithCompanion(ToolbarProfilesCompanion data) {
    return ToolbarProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      buttons: data.buttons.present ? data.buttons.value : this.buttons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToolbarProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('buttons: $buttons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn, buttons);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToolbarProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn &&
          other.buttons == this.buttons);
}

class ToolbarProfilesCompanion extends UpdateCompanion<ToolbarProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  final Value<String> buttons;
  const ToolbarProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.buttons = const Value.absent(),
  });
  ToolbarProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isBuiltIn = const Value.absent(),
    required String buttons,
  }) : name = Value(name),
       buttons = Value(buttons);
  static Insertable<ToolbarProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
    Expression<String>? buttons,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (buttons != null) 'buttons': buttons,
    });
  }

  ToolbarProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isBuiltIn,
    Value<String>? buttons,
  }) {
    return ToolbarProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      buttons: buttons ?? this.buttons,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (buttons.present) {
      map['buttons'] = Variable<String>(buttons.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToolbarProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('buttons: $buttons')
          ..write(')'))
        .toString();
  }
}

class $NotificationPatternsTable extends NotificationPatterns
    with TableInfo<$NotificationPatternsTable, NotificationPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, pattern, title, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationPattern> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationPattern(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $NotificationPatternsTable createAlias(String alias) {
    return $NotificationPatternsTable(attachedDatabase, alias);
  }
}

class NotificationPattern extends DataClass
    implements Insertable<NotificationPattern> {
  final int id;
  final String pattern;
  final String title;
  final bool enabled;
  const NotificationPattern({
    required this.id,
    required this.pattern,
    required this.title,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern'] = Variable<String>(pattern);
    map['title'] = Variable<String>(title);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  NotificationPatternsCompanion toCompanion(bool nullToAbsent) {
    return NotificationPatternsCompanion(
      id: Value(id),
      pattern: Value(pattern),
      title: Value(title),
      enabled: Value(enabled),
    );
  }

  factory NotificationPattern.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationPattern(
      id: serializer.fromJson<int>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      title: serializer.fromJson<String>(json['title']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pattern': serializer.toJson<String>(pattern),
      'title': serializer.toJson<String>(title),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  NotificationPattern copyWith({
    int? id,
    String? pattern,
    String? title,
    bool? enabled,
  }) => NotificationPattern(
    id: id ?? this.id,
    pattern: pattern ?? this.pattern,
    title: title ?? this.title,
    enabled: enabled ?? this.enabled,
  );
  NotificationPattern copyWithCompanion(NotificationPatternsCompanion data) {
    return NotificationPattern(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      title: data.title.present ? data.title.value : this.title,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPattern(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('title: $title, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pattern, title, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationPattern &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.title == this.title &&
          other.enabled == this.enabled);
}

class NotificationPatternsCompanion
    extends UpdateCompanion<NotificationPattern> {
  final Value<int> id;
  final Value<String> pattern;
  final Value<String> title;
  final Value<bool> enabled;
  const NotificationPatternsCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.title = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  NotificationPatternsCompanion.insert({
    this.id = const Value.absent(),
    required String pattern,
    required String title,
    this.enabled = const Value.absent(),
  }) : pattern = Value(pattern),
       title = Value(title);
  static Insertable<NotificationPattern> custom({
    Expression<int>? id,
    Expression<String>? pattern,
    Expression<String>? title,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (title != null) 'title': title,
      if (enabled != null) 'enabled': enabled,
    });
  }

  NotificationPatternsCompanion copyWith({
    Value<int>? id,
    Value<String>? pattern,
    Value<String>? title,
    Value<bool>? enabled,
  }) {
    return NotificationPatternsCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      title: title ?? this.title,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPatternsCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('title: $title, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HostGroupsTable hostGroups = $HostGroupsTable(this);
  late final $HostsTable hosts = $HostsTable(this);
  late final $ToolbarProfilesTable toolbarProfiles = $ToolbarProfilesTable(
    this,
  );
  late final $NotificationPatternsTable notificationPatterns =
      $NotificationPatternsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hostGroups,
    hosts,
    toolbarProfiles,
    notificationPatterns,
  ];
}

typedef $$HostGroupsTableCreateCompanionBuilder =
    HostGroupsCompanion Function({
      required String id,
      required String name,
      Value<int> sortOrder,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$HostGroupsTableUpdateCompanionBuilder =
    HostGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<String?> icon,
      Value<int> rowid,
    });

final class $$HostGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $HostGroupsTable, HostGroup> {
  $$HostGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HostsTable, List<Host>> _hostsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.hosts,
    aliasName: $_aliasNameGenerator(db.hostGroups.id, db.hosts.groupId),
  );

  $$HostsTableProcessedTableManager get hostsRefs {
    final manager = $$HostsTableTableManager(
      $_db,
      $_db.hosts,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HostGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $HostGroupsTable> {
  $$HostGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hostsRefs(
    Expression<bool> Function($$HostsTableFilterComposer f) f,
  ) {
    final $$HostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hosts,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostsTableFilterComposer(
            $db: $db,
            $table: $db.hosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HostGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $HostGroupsTable> {
  $$HostGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HostGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HostGroupsTable> {
  $$HostGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> hostsRefs<T extends Object>(
    Expression<T> Function($$HostsTableAnnotationComposer a) f,
  ) {
    final $$HostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hosts,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostsTableAnnotationComposer(
            $db: $db,
            $table: $db.hosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HostGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HostGroupsTable,
          HostGroup,
          $$HostGroupsTableFilterComposer,
          $$HostGroupsTableOrderingComposer,
          $$HostGroupsTableAnnotationComposer,
          $$HostGroupsTableCreateCompanionBuilder,
          $$HostGroupsTableUpdateCompanionBuilder,
          (HostGroup, $$HostGroupsTableReferences),
          HostGroup,
          PrefetchHooks Function({bool hostsRefs})
        > {
  $$HostGroupsTableTableManager(_$AppDatabase db, $HostGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HostGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HostGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HostGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostGroupsCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostGroupsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HostGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hostsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (hostsRefs) db.hosts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hostsRefs)
                    await $_getPrefetchedData<
                      HostGroup,
                      $HostGroupsTable,
                      Host
                    >(
                      currentTable: table,
                      referencedTable: $$HostGroupsTableReferences
                          ._hostsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HostGroupsTableReferences(db, table, p0).hostsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HostGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HostGroupsTable,
      HostGroup,
      $$HostGroupsTableFilterComposer,
      $$HostGroupsTableOrderingComposer,
      $$HostGroupsTableAnnotationComposer,
      $$HostGroupsTableCreateCompanionBuilder,
      $$HostGroupsTableUpdateCompanionBuilder,
      (HostGroup, $$HostGroupsTableReferences),
      HostGroup,
      PrefetchHooks Function({bool hostsRefs})
    >;
typedef $$HostsTableCreateCompanionBuilder =
    HostsCompanion Function({
      required String id,
      required String label,
      required String hostname,
      Value<int> port,
      required String username,
      Value<String?> groupId,
      Value<String> authType,
      Value<String?> passwordRef,
      Value<String?> privateKeyRef,
      Value<String?> totpSecretRef,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime?> lastConnectedAt,
      Value<int> rowid,
    });
typedef $$HostsTableUpdateCompanionBuilder =
    HostsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> hostname,
      Value<int> port,
      Value<String> username,
      Value<String?> groupId,
      Value<String> authType,
      Value<String?> passwordRef,
      Value<String?> privateKeyRef,
      Value<String?> totpSecretRef,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime?> lastConnectedAt,
      Value<int> rowid,
    });

final class $$HostsTableReferences
    extends BaseReferences<_$AppDatabase, $HostsTable, Host> {
  $$HostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HostGroupsTable _groupIdTable(_$AppDatabase db) => db.hostGroups
      .createAlias($_aliasNameGenerator(db.hosts.groupId, db.hostGroups.id));

  $$HostGroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$HostGroupsTableTableManager(
      $_db,
      $_db.hostGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HostsTableFilterComposer extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateKeyRef => $composableBuilder(
    column: $table.privateKeyRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totpSecretRef => $composableBuilder(
    column: $table.totpSecretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HostGroupsTableFilterComposer get groupId {
    final $$HostGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.hostGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostGroupsTableFilterComposer(
            $db: $db,
            $table: $db.hostGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HostsTableOrderingComposer
    extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostname => $composableBuilder(
    column: $table.hostname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateKeyRef => $composableBuilder(
    column: $table.privateKeyRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totpSecretRef => $composableBuilder(
    column: $table.totpSecretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HostGroupsTableOrderingComposer get groupId {
    final $$HostGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.hostGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.hostGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HostsTable> {
  $$HostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get hostname =>
      $composableBuilder(column: $table.hostname, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privateKeyRef => $composableBuilder(
    column: $table.privateKeyRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totpSecretRef => $composableBuilder(
    column: $table.totpSecretRef,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  $$HostGroupsTableAnnotationComposer get groupId {
    final $$HostGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.hostGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HostGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.hostGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HostsTable,
          Host,
          $$HostsTableFilterComposer,
          $$HostsTableOrderingComposer,
          $$HostsTableAnnotationComposer,
          $$HostsTableCreateCompanionBuilder,
          $$HostsTableUpdateCompanionBuilder,
          (Host, $$HostsTableReferences),
          Host,
          PrefetchHooks Function({bool groupId})
        > {
  $$HostsTableTableManager(_$AppDatabase db, $HostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> hostname = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> passwordRef = const Value.absent(),
                Value<String?> privateKeyRef = const Value.absent(),
                Value<String?> totpSecretRef = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostsCompanion(
                id: id,
                label: label,
                hostname: hostname,
                port: port,
                username: username,
                groupId: groupId,
                authType: authType,
                passwordRef: passwordRef,
                privateKeyRef: privateKeyRef,
                totpSecretRef: totpSecretRef,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastConnectedAt: lastConnectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String hostname,
                Value<int> port = const Value.absent(),
                required String username,
                Value<String?> groupId = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> passwordRef = const Value.absent(),
                Value<String?> privateKeyRef = const Value.absent(),
                Value<String?> totpSecretRef = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostsCompanion.insert(
                id: id,
                label: label,
                hostname: hostname,
                port: port,
                username: username,
                groupId: groupId,
                authType: authType,
                passwordRef: passwordRef,
                privateKeyRef: privateKeyRef,
                totpSecretRef: totpSecretRef,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastConnectedAt: lastConnectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HostsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$HostsTableReferences
                                    ._groupIdTable(db),
                                referencedColumn: $$HostsTableReferences
                                    ._groupIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HostsTable,
      Host,
      $$HostsTableFilterComposer,
      $$HostsTableOrderingComposer,
      $$HostsTableAnnotationComposer,
      $$HostsTableCreateCompanionBuilder,
      $$HostsTableUpdateCompanionBuilder,
      (Host, $$HostsTableReferences),
      Host,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$ToolbarProfilesTableCreateCompanionBuilder =
    ToolbarProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isBuiltIn,
      required String buttons,
    });
typedef $$ToolbarProfilesTableUpdateCompanionBuilder =
    ToolbarProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isBuiltIn,
      Value<String> buttons,
    });

class $$ToolbarProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ToolbarProfilesTable> {
  $$ToolbarProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buttons => $composableBuilder(
    column: $table.buttons,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ToolbarProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ToolbarProfilesTable> {
  $$ToolbarProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buttons => $composableBuilder(
    column: $table.buttons,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ToolbarProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToolbarProfilesTable> {
  $$ToolbarProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<String> get buttons =>
      $composableBuilder(column: $table.buttons, builder: (column) => column);
}

class $$ToolbarProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToolbarProfilesTable,
          ToolbarProfile,
          $$ToolbarProfilesTableFilterComposer,
          $$ToolbarProfilesTableOrderingComposer,
          $$ToolbarProfilesTableAnnotationComposer,
          $$ToolbarProfilesTableCreateCompanionBuilder,
          $$ToolbarProfilesTableUpdateCompanionBuilder,
          (
            ToolbarProfile,
            BaseReferences<
              _$AppDatabase,
              $ToolbarProfilesTable,
              ToolbarProfile
            >,
          ),
          ToolbarProfile,
          PrefetchHooks Function()
        > {
  $$ToolbarProfilesTableTableManager(
    _$AppDatabase db,
    $ToolbarProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToolbarProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToolbarProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToolbarProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<String> buttons = const Value.absent(),
              }) => ToolbarProfilesCompanion(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                buttons: buttons,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
                required String buttons,
              }) => ToolbarProfilesCompanion.insert(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                buttons: buttons,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ToolbarProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToolbarProfilesTable,
      ToolbarProfile,
      $$ToolbarProfilesTableFilterComposer,
      $$ToolbarProfilesTableOrderingComposer,
      $$ToolbarProfilesTableAnnotationComposer,
      $$ToolbarProfilesTableCreateCompanionBuilder,
      $$ToolbarProfilesTableUpdateCompanionBuilder,
      (
        ToolbarProfile,
        BaseReferences<_$AppDatabase, $ToolbarProfilesTable, ToolbarProfile>,
      ),
      ToolbarProfile,
      PrefetchHooks Function()
    >;
typedef $$NotificationPatternsTableCreateCompanionBuilder =
    NotificationPatternsCompanion Function({
      Value<int> id,
      required String pattern,
      required String title,
      Value<bool> enabled,
    });
typedef $$NotificationPatternsTableUpdateCompanionBuilder =
    NotificationPatternsCompanion Function({
      Value<int> id,
      Value<String> pattern,
      Value<String> title,
      Value<bool> enabled,
    });

class $$NotificationPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationPatternsTable> {
  $$NotificationPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationPatternsTable> {
  $$NotificationPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationPatternsTable> {
  $$NotificationPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$NotificationPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationPatternsTable,
          NotificationPattern,
          $$NotificationPatternsTableFilterComposer,
          $$NotificationPatternsTableOrderingComposer,
          $$NotificationPatternsTableAnnotationComposer,
          $$NotificationPatternsTableCreateCompanionBuilder,
          $$NotificationPatternsTableUpdateCompanionBuilder,
          (
            NotificationPattern,
            BaseReferences<
              _$AppDatabase,
              $NotificationPatternsTable,
              NotificationPattern
            >,
          ),
          NotificationPattern,
          PrefetchHooks Function()
        > {
  $$NotificationPatternsTableTableManager(
    _$AppDatabase db,
    $NotificationPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationPatternsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationPatternsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => NotificationPatternsCompanion(
                id: id,
                pattern: pattern,
                title: title,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pattern,
                required String title,
                Value<bool> enabled = const Value.absent(),
              }) => NotificationPatternsCompanion.insert(
                id: id,
                pattern: pattern,
                title: title,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationPatternsTable,
      NotificationPattern,
      $$NotificationPatternsTableFilterComposer,
      $$NotificationPatternsTableOrderingComposer,
      $$NotificationPatternsTableAnnotationComposer,
      $$NotificationPatternsTableCreateCompanionBuilder,
      $$NotificationPatternsTableUpdateCompanionBuilder,
      (
        NotificationPattern,
        BaseReferences<
          _$AppDatabase,
          $NotificationPatternsTable,
          NotificationPattern
        >,
      ),
      NotificationPattern,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HostGroupsTableTableManager get hostGroups =>
      $$HostGroupsTableTableManager(_db, _db.hostGroups);
  $$HostsTableTableManager get hosts =>
      $$HostsTableTableManager(_db, _db.hosts);
  $$ToolbarProfilesTableTableManager get toolbarProfiles =>
      $$ToolbarProfilesTableTableManager(_db, _db.toolbarProfiles);
  $$NotificationPatternsTableTableManager get notificationPatterns =>
      $$NotificationPatternsTableTableManager(_db, _db.notificationPatterns);
}
