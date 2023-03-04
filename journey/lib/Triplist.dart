import 'dart:collection';

import 'package:flutter/material.dart';
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute<Trip>(
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
              itemBuilder: (context, index) => Dismissible(
                  onDismissed: (direction) async {
                    // Remove the item from the data source.
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('${trips[index].name.toString()} deleted')));
                    await tripStopDaoProvider.deleteTrip(trips[index]);

                    // Then show a snackbar.
                  },
                  key: Key(trips[index].name.toString()),
                  background: Container(color: Colors.red),
                  child: ListTile(
                      title: Text(trips[index].name.toString()),
                      subtitle: const Text('Click here to edit'),
                      onTap: () async {
                        LinkedHashMap<String, Stop> stops = LinkedHashMap();
                        if (trips[index].id != null) {
                          List<Stop> stopsList = await tripStopDaoProvider
                              .getStopsForTrip(trips[index].id!);
                          List<TripStop> nameStops = await tripStopDaoProvider
                              .getTripStopForTrip(trips[index].id!);
                          for (int i = 0; i < stopsList.length; i++) {
                            String stopName = "";
                            for (int j = 0; j < nameStops.length; j++) {
                              if (stopsList[i].id == nameStops[j].stop_id) {
                                stopName = nameStops[j].name_stop ?? "";
                              }
                            }
                            stops[stopName] = stopsList[i];
                          }
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.push(context, MaterialPageRoute<Trip>(
                          builder: (BuildContext context) {
                            return InsertTrip(trip: trips[index], stops: stops);
                          },
                          // ignore: avoid_print
                        )).then((value) async {
                          print(value);
                          var k = await tripStopDaoProvider
                              .getTripStopForTrip(value?.id ?? 0);

                          print(k);
                        });
                      })),
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
