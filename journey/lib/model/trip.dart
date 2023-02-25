import 'package:floor/floor.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

@Entity(
  tableName: 'stops',
)
class Stop {
  @PrimaryKey(autoGenerate: true)
  int? id;
  double lat;
  double lng;
  String address;
  Stop({required this.lat, this.id, required this.lng, required this.address});
}

@Entity(tableName: 'trips')
class Trip {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: "name")
  String name;
  @TypeConverters([DateTimeConverter])
  DateTime updated;

  Trip({required this.name, this.id, required this.updated});
}

@Entity(
  tableName: 'trip_stop',
  primaryKeys: ['trip_id', 'stop_id'],
  foreignKeys: [
    ForeignKey(
      childColumns: ['trip_id'],
      parentColumns: ['id'],
      entity: Trip,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['stop_id'],
      parentColumns: ['id'],
      entity: Stop,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class TripStop {
  int trip_id;
  int stop_id;
  String name_stop;

  TripStop(
      {required this.trip_id, required this.stop_id, required this.name_stop});
}
