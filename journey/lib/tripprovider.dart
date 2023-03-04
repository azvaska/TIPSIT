import 'package:flutter/foundation.dart';
import 'package:journey/dao/trip.dart';
import 'package:journey/db.dart';
import 'package:journey/model/trip.dart';

class TripStopProvider extends ChangeNotifier {
  late TripStopDao _tripStopDao;
  late TripDao _tripDao;
  late StopDao _stopDao;

  TripStopProvider(AppDatabase database) {
    _tripStopDao = database.tripStopDao;
    _tripDao = database.tripDao;
    _stopDao = database.stopDao;
  }

  Future<List<Trip>> getTrips() async {
    return _tripDao.findAllTrips();
  }

  Future<List<Stop>> getStops([int? id]) async {
    return _stopDao.findAllStops();
  }

  Future<List<Stop>> getStopsForTrip(int tripId) async {
    return _tripStopDao.getStopsForTrip(tripId);
  }

  Future<List<TripStop>> getTripStopForTrip(int tripId) async {
    return _tripStopDao.getTripStopForTrip(tripId);
  }

  Future<TripStop?> getTripStopForStop(int tripId) async {
    return _tripStopDao.getTripStopForStop(tripId);
  }

  Future<List<Stop>> getAllStopsNear(double lat, double lng, double limit) {
    return _tripStopDao.getAllStopsNear(lat, lng, limit);
  }

  Future<void> updateStop(Stop stop) async {
    var k = await _stopDao.updateStop(stop);
    notifyListeners();
    return k;
  }

  Future<void> updateTrip(Trip trip) async {
    var k = await _tripDao.updateTrip(trip);
    notifyListeners();
    return k;
  }

  Future<int> insertTrip(Trip trip) async {
    var k = await _tripDao.insertTrip(trip);
    notifyListeners();
    return k;
  }

  Future<int> insertStop(Stop stop) async {
    var k = await _stopDao.insertStop(stop);
    notifyListeners();
    return k;
  }

  Future<void> insertTripStop(TripStop tripstop) async {
    var k = await _tripStopDao.insertTripStop(tripstop);
    notifyListeners();
    return k;
  }

  Future<void> deleteTripStop(TripStop tripstop) async {
    // notifyListeners();
    return _tripStopDao.deleteTripStop(tripstop);
  }

  Future<void> deleteTrip(Trip trip) async {
    List<Stop> stops = await _tripStopDao.getStopsForTrip(trip.id!);

    await _tripDao.deleteTrip(trip);
    stops.forEach((element) {
      _tripStopDao.getTripsForStop(element.id!).then((value) {
        if (value.isEmpty) _stopDao.deleteStop(element);
      });
    });
    notifyListeners();
  }
}
