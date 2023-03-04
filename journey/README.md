# journey

A simple application that allows you to design a trip

## Database

The database was created thanks to the library floor, there are the following tables

- **Trip** With a name and an id that rappresents the trip
- **Stop** With position,address That rappresents an actual point where the user will stop
- **TripStop** With a reference to an instance of Trip and Stop that rappresents the M to m relationship between Trip and stop

### TripStop

If a Trip is deleted then all the TripStop saved will be dropped since we have the cascade OnDelete

```dart
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
  String? name_stop;

  TripStop(
      {required this.trip_id, required this.stop_id, required this.name_stop});
}
```

### Stop

this entity is special since for an optimization of the storage if two stops are near less than 13m then they will be the same stop

```Dart
List<Stop> possibleStops = await tripStopDaoProvider.getAllStopsNear(stop.lat, stop.lng, precision);
  if (possibleStops.isNotEmpty) {
    stop = possibleStops.first;
  } else {
    stop.id = await tripStopDaoProvider.insertStop(stop);
  } 
```

This is the actual query to the database, the precision is 0.0001

```dart
  @Query(
      'SELECT * FROM stops where lat > :lat - :limit and lat < :lat + :limit and lng > :lng - :limit and lng < :lng + :limit limit 1')
  Future<List<Stop>> getAllStopsNear(double lat, double lng, double limit);
```

### Dao

To access the dabase we create a **DAO** (data access object) that will allow us to query the actual database

```dart
@dao
abstract class StopDao {
  @Query('SELECT * FROM stops')
  Future<List<Stop>> findAllStops();

  @Query('SELECT * FROM stops')
  Stream<List<Stop>> watchAllStops();

  @Query('SELECT * FROM stops WHERE stops_id = :stopId')
  Stream<List<Stop>> watchStopsByGroceryListId(int stopId);

  @Query('SELECT * FROM stops WHERE id = :id')
  Stream<Stop?> findStopById(int id);

  @insert
  Future<int> insertStop(Stop stop);

  @delete
  Future<void> deleteStop(Stop stop);

  @update
  Future<void> updateStop(Stop stop);
}
```

## Centralized State

The centralized state is used to access the dao and manage the state is implemented thanks to the package **Provider** to initialize the provider we first need to initialize the database

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the database instance by awaiting the result of databaseBuilder
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  check_permission();

  runApp(MyApp(database));
}
```

To make the provider useful we initialize like this

```dart

    return ChangeNotifierProvider(
      create: (_) => TripStopProvider(database),
      child: const MaterialApp(
        title: 'My App',
        home: TripList(),
      ),
    );
```

Then for example to retrive all the stops of a trip we useit like this:

```dart
List<Stop> stopsList = await tripStopDaoProvider.getStopsForTrip(trips[index].id!);
```

## GoogleMaps
To have the Stops shown we first need to serialized them into ```markers```
```dart
var firstValue = widget.stopList.entries.first;
_markers.add(Marker(
  position: LatLng(firstValue.value.lat, firstValue.value.lng),
  markerId: MarkerId(firstValue.key),
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  infoWindow: InfoWindow(
    title: firstValue.key,
    snippet: firstValue.value.address,
  ),
));

for (var i = 1; i < widget.stopList.entries.length - 1; i++) {
  MapEntry<String, Stop> entry = widget.stopList.entries.elementAt(i);
  latlonlist.add(LatLng(
    entry.value.lat,
    entry.value.lng,
  ));
  _markers.add(Marker(
    position: LatLng(entry.value.lat, entry.value.lng),
    markerId: MarkerId(entry.key),
    icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    infoWindow: InfoWindow(
      title: entry.key,
      snippet: entry.value.address,
    ),
  ));
}
if (widget.stopList.entries.length > 1) {
  latlonlist.add(LatLng(
    widget.stopList.entries.last.value.lat,
    widget.stopList.entries.last.value.lng,
  ));
  _markers.add(Marker(
    position: LatLng(widget.stopList.entries.last.value.lat,
        widget.stopList.entries.last.value.lng),
    markerId: MarkerId(widget.stopList.entries.last.key),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    infoWindow: InfoWindow(
      title: widget.stopList.entries.last.key,
      snippet: widget.stopList.entries.last.value.address,
    ),
  ));
}
```
### Directions 
To show directions i use the google maps api to calculate the path
```dart
polylinePoints = PolylinePoints();
polylineCoordinates = [];
// Generating the list of coordinates to be used for
// drawing the polylines
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  GoogleMapsAPIKey, // Google Maps API Key
  PointLatLng(startLatitude, startLongitude),
  PointLatLng(destinationLatitude, destinationLongitude),
  travelMode: TravelMode.driving,
);
// Adding the coordinates to the list
if (result.points.isNotEmpty) {
  result.points.forEach((PointLatLng point) {
    polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  });
}
// Defining an ID
final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
PolylineId id = PolylineId(polylineIdVal);
_polylineIdCounter++;
// Initializing Polyline
Polyline polyline = Polyline(
  polylineId: id,
  color: lineColor[math.Random().nextInt(lineColor.length)],
  points: polylineCoordinates,
  width: 5,
);
return {id: polyline};
```
i use the class polyline to then show on the actual map
```dart
          polylines: Set<Polyline>.of(polylines.values),
```
The google map widget also support the possibility of showing the current user location and it's required. <br>
It will automaticaly zoom to the current position once it's avabile
## Open map
With a button you can open the real google maps 

