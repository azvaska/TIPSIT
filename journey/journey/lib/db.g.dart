// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    String dbPath = path;
    print('db location : ' + dbPath);
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TripDao? _tripDaoInstance;

  TripStopDao? _tripStopDaoInstance;

  StopDao? _stopDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `trips` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `updated` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `stops` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `lat` REAL NOT NULL, `lng` REAL NOT NULL, `address` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `trip_stop` (`trip_id` INTEGER NOT NULL, `stop_id` INTEGER NOT NULL, FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`stop_id`) REFERENCES `stops` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`trip_id`, `stop_id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TripDao get tripDao {
    return _tripDaoInstance ??= _$TripDao(database, changeListener);
  }

  @override
  TripStopDao get tripStopDao {
    return _tripStopDaoInstance ??= _$TripStopDao(database, changeListener);
  }

  @override
  StopDao get stopDao {
    return _stopDaoInstance ??= _$StopDao(database, changeListener);
  }
}

class _$TripDao extends TripDao {
  _$TripDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _tripInsertionAdapter = InsertionAdapter(
            database,
            'trips',
            (Trip item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'updated': _dateTimeConverter.encode(item.updated)
                },
            changeListener),
        _tripUpdateAdapter = UpdateAdapter(
            database,
            'trips',
            ['id'],
            (Trip item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'updated': _dateTimeConverter.encode(item.updated)
                },
            changeListener),
        _tripDeletionAdapter = DeletionAdapter(
            database,
            'trips',
            ['id'],
            (Trip item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'updated': _dateTimeConverter.encode(item.updated)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Trip> _tripInsertionAdapter;

  final UpdateAdapter<Trip> _tripUpdateAdapter;

  final DeletionAdapter<Trip> _tripDeletionAdapter;

  @override
  Future<List<Trip>> findAllTrips() async {
    return _queryAdapter.queryList('SELECT * FROM trips',
        mapper: (Map<String, Object?> row) => Trip(
            name: row['name'] as String,
            id: row['id'] as int?,
            updated: _dateTimeConverter.decode(row['updated'] as int)));
  }

  @override
  Stream<List<Trip>> watchAllTrips() {
    return _queryAdapter.queryListStream('SELECT * FROM trips',
        mapper: (Map<String, Object?> row) => Trip(
            name: row['name'] as String,
            id: row['id'] as int?,
            updated: _dateTimeConverter.decode(row['updated'] as int)),
        queryableName: 'trips',
        isView: false);
  }

  @override
  Stream<Trip?> findTripById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM trips WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Trip(
            name: row['name'] as String,
            id: row['id'] as int?,
            updated: _dateTimeConverter.decode(row['updated'] as int)),
        arguments: [id],
        queryableName: 'trips',
        isView: false);
  }

  @override
  Future<int> insertTrip(Trip trip) {
    return _tripInsertionAdapter.insertAndReturnId(
        trip, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    await _tripUpdateAdapter.update(trip, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTrip(Trip trip) async {
    await _tripDeletionAdapter.delete(trip);
  }
}

class _$TripStopDao extends TripStopDao {
  _$TripStopDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tripStopInsertionAdapter = InsertionAdapter(
            database,
            'trip_stop',
            (TripStop item) => <String, Object?>{
                  'trip_id': item.trip_id,
                  'stop_id': item.stop_id
                }),
        _tripStopUpdateAdapter = UpdateAdapter(
            database,
            'trip_stop',
            ['trip_id', 'stop_id'],
            (TripStop item) => <String, Object?>{
                  'trip_id': item.trip_id,
                  'stop_id': item.stop_id
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TripStop> _tripStopInsertionAdapter;

  final UpdateAdapter<TripStop> _tripStopUpdateAdapter;

  @override
  Future<List<Trip>> getTripsForStop(int stopId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM trips INNER JOIN trip_stop ON trips.id = trip_stop.trip_id WHERE trip_stop.stop_id = ?1',
        mapper: (Map<String, Object?> row) => Trip(name: row['name'] as String, id: row['id'] as int?, updated: _dateTimeConverter.decode(row['updated'] as int)),
        arguments: [stopId]);
  }

  @override
  Future<List<Stop>> getStopsForTrip(int tripId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM stops INNER JOIN trip_stop ON stops.id = trip_stop.stop_id WHERE trip_stop.trip_id = ?1',
        mapper: (Map<String, Object?> row) => Stop(lat: row['lat'] as double, id: row['id'] as int?, lng: row['lng'] as double, address: row['address'] as String),
        arguments: [tripId]);
  }

  @override
  Future<void> insertTripStop(TripStop tripStop) async {
    await _tripStopInsertionAdapter.insert(tripStop, OnConflictStrategy.ignore);
  }

  @override
  Future<void> updateTripStop(TripStop tripStop) async {
    await _tripStopUpdateAdapter.update(tripStop, OnConflictStrategy.abort);
  }
}

class _$StopDao extends StopDao {
  _$StopDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _stopInsertionAdapter = InsertionAdapter(
            database,
            'stops',
            (Stop item) => <String, Object?>{
                  'id': item.id,
                  'lat': item.lat,
                  'lng': item.lng,
                  'address': item.address
                },
            changeListener),
        _stopUpdateAdapter = UpdateAdapter(
            database,
            'stops',
            ['id'],
            (Stop item) => <String, Object?>{
                  'id': item.id,
                  'lat': item.lat,
                  'lng': item.lng,
                  'address': item.address
                },
            changeListener),
        _stopDeletionAdapter = DeletionAdapter(
            database,
            'stops',
            ['id'],
            (Stop item) => <String, Object?>{
                  'id': item.id,
                  'lat': item.lat,
                  'lng': item.lng,
                  'address': item.address
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Stop> _stopInsertionAdapter;

  final UpdateAdapter<Stop> _stopUpdateAdapter;

  final DeletionAdapter<Stop> _stopDeletionAdapter;

  @override
  Future<List<Stop>> findAllStops() async {
    return _queryAdapter.queryList('SELECT * FROM stops',
        mapper: (Map<String, Object?> row) => Stop(
            lat: row['lat'] as double,
            id: row['id'] as int?,
            lng: row['lng'] as double,
            address: row['address'] as String));
  }

  @override
  Stream<List<Stop>> watchAllStops() {
    return _queryAdapter.queryListStream('SELECT * FROM stops',
        mapper: (Map<String, Object?> row) => Stop(
            lat: row['lat'] as double,
            id: row['id'] as int?,
            lng: row['lng'] as double,
            address: row['address'] as String),
        queryableName: 'stops',
        isView: false);
  }

  @override
  Stream<List<Stop>> watchStopsByGroceryListId(int stopId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM stops WHERE stops_id = ?1',
        mapper: (Map<String, Object?> row) => Stop(
            lat: row['lat'] as double,
            id: row['id'] as int?,
            lng: row['lng'] as double,
            address: row['address'] as String),
        arguments: [stopId],
        queryableName: 'stops',
        isView: false);
  }

  @override
  Stream<Stop?> findStopById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM stops WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Stop(
            lat: row['lat'] as double,
            id: row['id'] as int?,
            lng: row['lng'] as double,
            address: row['address'] as String),
        arguments: [id],
        queryableName: 'stops',
        isView: false);
  }

  @override
  Future<int> insertStop(Stop stop) {
    return _stopInsertionAdapter.insertAndReturnId(
        stop, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateStop(Stop stop) async {
    await _stopUpdateAdapter.update(stop, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteStop(Stop stop) async {
    await _stopDeletionAdapter.delete(stop);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
