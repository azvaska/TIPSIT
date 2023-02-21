import 'package:floor/floor.dart';

import '../model/trip.dart';

@dao
abstract class TripDao {
  @Query('SELECT * FROM trips')
  Future<List<Trip>> findAllTrips();

  @Query('SELECT * FROM trips')
  Stream<List<Trip>> watchAllTrips();

  @Query('SELECT * FROM trips WHERE id = :id')
  Stream<Trip?> findTripById(int id);

  @insert
  Future<int> insertTrip(Trip trip);

  @update
  Future<void> updateTrip(Trip trip);

  @delete
  Future<void> deleteTrip(Trip trip);
}

@dao
abstract class TripStopDao {
  @Query(
      'SELECT * FROM trips INNER JOIN trip_stop ON trips.id = trip_stop.trip_id WHERE trip_stop.stop_id = :stopId')
  Future<List<Trip>> getTripsForStop(int stopId);

  @Query(
      'SELECT * FROM stops INNER JOIN trip_stop ON stops.id = trip_stop.stop_id WHERE trip_stop.trip_id = :tripId')
  Future<List<Stop>> getStopsForTrip(int tripId);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insertTripStop(TripStop tripStop);

  @update
  Future<void> updateTripStop(TripStop tripStop);
}

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
