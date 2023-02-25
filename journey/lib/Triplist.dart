import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:journey/insertStop.dart';
import 'package:journey/insertTrip.dart';
import 'package:journey/model/trip.dart';
import 'package:journey/tripprovider.dart';
import 'package:provider/provider.dart';

class TripList extends StatelessWidget {
  const TripList({super.key});

  @override
  Widget build(BuildContext context) {
    TripStopProvider tripStopDaoProvider =
        Provider.of<TripStopProvider>(context);

    /*
    Stop s = Stop(lat: 1, lng: 1);
Trip t = Trip(name: "idroscimmia", updated: DateTime.now());
    tripStopDaoProvider.insertTrip(t);
    
    .then((value) => 
    );
    tripStopDaoProvider
        .insertTripStop(TripStop(trip_id: t.id!, stop_id: s.id!));

    tripStopDaoProvider.insertStop(s);
*/
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute<int>(
            builder: (BuildContext context) {
              return const InsertTrip();
            },
          )).then((value) => print(value));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Stops for Trip 2'),
      ),
      body: FutureBuilder(
        future: tripStopDaoProvider.getTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final trips = snapshot.data;
            return ListView.builder(
              itemCount: trips!.length,
              itemBuilder: (context, index) => ListTile(
                  title: Text(trips[index].name.toString()),
                  subtitle: const Text('Click here to edit'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute<int>(
                      builder: (BuildContext context) {
                        return InsertTrip(trip: trips[index]);
                      },
                    )).then((value) => print(value));
                  }),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
