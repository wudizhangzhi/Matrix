import 'dart:convert';
import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';
import 'package:xterm/xterm.dart' as xterm;

enum SessionState { connecting, connected, disconnected, error }

class SshSession {
  final String id;
  final Host host;
  final xterm.Terminal terminal;

  SSHClient? _client;
  SSHSession? _shell;
  SessionState state = SessionState.connecting;
  String? errorMessage;

  final _stateController = StreamController<SessionState>.broadcast();
  Stream<SessionState> get stateStream => _stateController.stream;

  SshSession({required this.id, required this.host})
      : terminal = xterm.Terminal(maxLines: 10000);

  Future<void> connect() async {
    try {
      state = SessionState.connecting;
      _stateController.add(state);

      final socket = await SSHSocket.connect(host.hostname, host.port,
          timeout: const Duration(seconds: 10));

      // Resolve credentials
      String? password;
      if (host.passwordRef != null) {
        password = await SecureStore.read(host.passwordRef!);
      }

      List<SSHKeyPair>? identities;
      if (host.authType == 'privateKey' && host.privateKeyRef != null) {
        final pem = await SecureStore.read(host.privateKeyRef!);
        if (pem != null && pem.isNotEmpty) {
          identities = SSHKeyPair.fromPem(pem);
        }
      }

      _client = SSHClient(
        socket,
        username: host.username,
        identities: identities,
        onPasswordRequest: () => password ?? '',
        onUserInfoRequest: (request) {
          // Keyboard-interactive: return password for prompts
          return request.prompts.map((_) => password ?? '').toList();
        },
        keepAliveInterval: const Duration(seconds: 15),
      );

      _shell = await _client!.shell(
        pty: SSHPtyConfig(
          width: terminal.viewWidth,
          height: terminal.viewHeight,
        ),
      );

      // Pipe SSH stdout to terminal
      _shell!.stdout.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
        onDone: () {
          state = SessionState.disconnected;
          _stateController.add(state);
        },
      );

      _shell!.stderr.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
      );

      // Pipe terminal output (user keystrokes) to SSH
      terminal.onOutput = (data) {
        _shell?.write(utf8.encode(data));
      };

      // Handle terminal resize
      terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        _shell?.resizeTerminal(width, height);
      };

      state = SessionState.connected;
      _stateController.add(state);
    } catch (e) {
      state = SessionState.error;
      errorMessage = e.toString();
      _stateController.add(state);
    }
  }

  /// Write raw text (from Chinese input bar) to the SSH channel
  void writeText(String text) {
    _shell?.write(utf8.encode(text));
  }

  void close() {
    _shell?.close();
    _client?.close();
    state = SessionState.disconnected;
    _stateController.add(state);
    _stateController.close();
  }
}
