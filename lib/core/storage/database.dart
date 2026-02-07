import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class HostGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Hosts extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withLength(min: 1, max: 100)();
  TextColumn get hostname => text()();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text()();
  TextColumn get groupId => text().nullable().references(HostGroups, #id)();
  TextColumn get authType => text().withDefault(const Constant('password'))();
  TextColumn get passwordRef => text().nullable()();
  TextColumn get privateKeyRef => text().nullable()();
  TextColumn get totpSecretRef => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ToolbarProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  TextColumn get buttons => text()();
}

@DriftDatabase(tables: [Hosts, HostGroups, ToolbarProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(toolbarProfiles);
          }
        },
      );

  Future<List<Host>> getAllHosts() => select(hosts).get();
  Stream<List<Host>> watchAllHosts() => select(hosts).watch();

  Stream<List<Host>> watchHostsByGroup(String groupId) {
    return (select(hosts)..where((h) => h.groupId.equals(groupId))).watch();
  }

  Stream<List<Host>> watchUngroupedHosts() {
    return (select(hosts)..where((h) => h.groupId.isNull())).watch();
  }

  Future<void> insertHost(HostsCompanion host) => into(hosts).insert(host);

  Future<void> updateHost(HostsCompanion host) =>
      (update(hosts)..where((h) => h.id.equals(host.id.value))).write(host);

  Future<void> deleteHost(String id) =>
      (delete(hosts)..where((h) => h.id.equals(id))).go();

  Future<void> updateLastConnected(String id) =>
      (update(hosts)..where((h) => h.id.equals(id)))
          .write(HostsCompanion(lastConnectedAt: Value(DateTime.now())));

  Future<List<HostGroup>> getAllGroups() => select(hostGroups).get();

  Stream<List<HostGroup>> watchAllGroups() {
    return (select(hostGroups)..orderBy([(g) => OrderingTerm.asc(g.sortOrder)])).watch();
  }

  Future<void> insertGroup(HostGroupsCompanion group) => into(hostGroups).insert(group);

  Future<void> updateGroup(HostGroupsCompanion group) =>
      (update(hostGroups)..where((g) => g.id.equals(group.id.value))).write(group);

  Future<void> deleteGroup(String id) =>
      (delete(hostGroups)..where((g) => g.id.equals(id))).go();

  Future<List<ToolbarProfile>> getAllToolbarProfiles() =>
      select(toolbarProfiles).get();

  Stream<List<ToolbarProfile>> watchAllToolbarProfiles() =>
      select(toolbarProfiles).watch();

  Future<int> insertToolbarProfile(ToolbarProfilesCompanion profile) =>
      into(toolbarProfiles).insert(profile);

  Future<void> updateToolbarProfile(ToolbarProfilesCompanion profile) =>
      (update(toolbarProfiles)..where((p) => p.id.equals(profile.id.value)))
          .write(profile);

  Future<void> deleteToolbarProfile(int id) =>
      (delete(toolbarProfiles)..where((p) => p.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'matrix_terminal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
