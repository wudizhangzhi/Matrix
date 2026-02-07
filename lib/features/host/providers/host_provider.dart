import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final hostGroupsProvider = StreamProvider<List<HostGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllGroups();
});

final allHostsProvider = StreamProvider<List<Host>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllHosts();
});

final hostsByGroupProvider =
    StreamProvider.family<List<Host>, String>((ref, groupId) {
  final db = ref.watch(databaseProvider);
  return db.watchHostsByGroup(groupId);
});

final ungroupedHostsProvider = StreamProvider<List<Host>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUngroupedHosts();
});

class HostNotifier {
  final AppDatabase _db;
  HostNotifier(this._db);

  Future<void> addHost({
    required String label,
    required String hostname,
    required int port,
    required String username,
    required String authType,
    String? groupId,
    String? password,
    String? privateKey,
    String? totpSecret,
  }) async {
    final id = _uuid.v4();
    String? passwordRef;
    String? privateKeyRef;
    String? totpSecretRef;

    if (password != null) {
      passwordRef = 'host_pwd_$id';
      await SecureStore.write(passwordRef, password);
    }
    if (privateKey != null) {
      privateKeyRef = 'host_key_$id';
      await SecureStore.write(privateKeyRef, privateKey);
    }
    if (totpSecret != null) {
      totpSecretRef = 'host_totp_$id';
      await SecureStore.write(totpSecretRef, totpSecret);
    }

    await _db.insertHost(HostsCompanion(
      id: Value(id),
      label: Value(label),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      groupId: Value(groupId),
      authType: Value(authType),
      passwordRef: Value(passwordRef),
      privateKeyRef: Value(privateKeyRef),
      totpSecretRef: Value(totpSecretRef),
    ));
  }

  Future<void> updateHost({
    required String id,
    required String label,
    required String hostname,
    required int port,
    required String username,
    required String authType,
    String? groupId,
    String? password,
    String? privateKey,
    String? totpSecret,
  }) async {
    String? passwordRef;
    String? privateKeyRef;
    String? totpSecretRef;

    if (password != null) {
      passwordRef = 'host_pwd_$id';
      await SecureStore.write(passwordRef, password);
    }
    if (privateKey != null) {
      privateKeyRef = 'host_key_$id';
      await SecureStore.write(privateKeyRef, privateKey);
    }
    if (totpSecret != null) {
      totpSecretRef = 'host_totp_$id';
      await SecureStore.write(totpSecretRef, totpSecret);
    }

    await _db.updateHost(HostsCompanion(
      id: Value(id),
      label: Value(label),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      groupId: Value(groupId),
      authType: Value(authType),
      passwordRef: Value(passwordRef),
      privateKeyRef: Value(privateKeyRef),
      totpSecretRef: Value(totpSecretRef),
    ));
  }

  Future<void> deleteHost(String id) async {
    await SecureStore.remove('host_pwd_$id');
    await SecureStore.remove('host_key_$id');
    await SecureStore.remove('host_totp_$id');
    await _db.deleteHost(id);
  }

  Future<void> addGroup(String name) async {
    await _db.insertGroup(HostGroupsCompanion(
      id: Value(_uuid.v4()),
      name: Value(name),
    ));
  }

  Future<void> deleteGroup(String id) async {
    await _db.deleteGroup(id);
  }
}

final hostNotifierProvider = Provider<HostNotifier>((ref) {
  return HostNotifier(ref.watch(databaseProvider));
});
