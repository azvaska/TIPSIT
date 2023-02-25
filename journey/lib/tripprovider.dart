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

  Future<List<Stop>> getStops() async {
    return _stopDao.findAllStops();
  }

  Future<List<Stop>> getStopsForTrip(int tripId) async {
    return _tripStopDao.getStopsForTrip(tripId);
  }

  Future<void> updateStop(Stop stop) async {
    var k = _stopDao.updateStop(stop);
    notifyListeners();
    return k;
  }

  Future<int> insertTrip(Trip trip) async {
    var k = await _tripDao.insertTrip(trip);
    notifyListeners();
    return k;
  }

  Future<int> insertStop(Stop stop) async {
    var k = _stopDao.insertStop(stop);
    notifyListeners();
    return k;
  }

  Future<void> insertTripStop(TripStop tripstop) async {
    var k = _tripStopDao.insertTripStop(tripstop);
    notifyListeners();
    return k;
  }
}
