import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:journey/insertMap.dart';
import 'package:journey/insertStop.dart';
import 'package:journey/tripprovider.dart';
import 'package:journey/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

import 'model/trip.dart';

class InsertTrip extends StatefulWidget {
  const InsertTrip({super.key, this.trip});
  final Trip? trip;
  @override
  State<InsertTrip> createState() => _InsertTripState();
}

class _InsertTripState extends State<InsertTrip> {
  List<Stop> stops = [];
  Trip? currentTrip = null;
  late TripStopProvider tripStopDaoProvider;
  TextEditingController textController = TextEditingController();
  double current_lat = 45.4869;
  double current_lng = 12.3768;
  double _rotation = 0;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    tripStopDaoProvider = Provider.of<TripStopProvider>(context, listen: false);
    print(availableHeight % 10);
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            for (var i = 0; i < stops.length; i++) {
              await tripStopDaoProvider.insertTripStop(
                  TripStop(trip_id: currentTrip!.id!, stop_id: stops[i].id!));
            }
            Navigator.pop(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.check),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  width: 200,
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    List<Location> locations = await locationFromAddress(
                        textController.text,
                        localeIdentifier: "IT");
                    var addresses = await placemarkFromCoordinates(
                        locations[0].latitude, locations[0].longitude);
                    Placemark placeMark = addresses[0];

                    String addressStr = address_serializer(placeMark);

                    setState(() {
                      stops.add(Stop(
                          lat: locations[0].latitude,
                          lng: locations[0].longitude,
                          address: addressStr));
                    });

                    print(current_lng);
                  },
                ),
              ],
            ),
            Text("Stops for this Trip:"),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stops.length,
                itemBuilder: (context, index) => ListTile(
                    title: Text("${stops[index].address},${stops[index].lng}"),
                    subtitle: const Text('Click here to edit'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute<int>(
                        builder: (BuildContext context) {
                          return ManageStop(stop: stops[index]);
                        },
                      )).then((value) => print(value));
                    }),
              ),
            ),
            Text("Saved Stops in the db:"),
            Expanded(
              child: FutureBuilder(
                future: tripStopDaoProvider.getStops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final stops = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: stops!.length,
                      itemBuilder: (context, index) => ListTile(
                          title: Text(stops[index].lat.toString()),
                          subtitle: const Text('Click here to edit'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute<int>(
                              builder: (BuildContext context) {
                                return ManageStop(stop: stops[index]);
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
            ),
            InsertMap(
              stopList: stops,
              key: UniqueKey(),
            )
          ],
        ),
      ),
    );
  }
}
