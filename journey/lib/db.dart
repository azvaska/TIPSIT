import 'package:floor/floor.dart';
import 'package:journey/dao/trip.dart';

import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'model/trip.dart';

part 'db.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Trip, Stop, TripStop])
abstract class AppDatabase extends FloorDatabase {
  TripDao get tripDao;
  TripStopDao get tripStopDao;

  StopDao get stopDao;
}
