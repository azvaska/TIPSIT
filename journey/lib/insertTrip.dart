import 'dart:collection';

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
  LinkedHashMap<String, Stop> stops = LinkedHashMap<String, Stop>();
  Trip? currentTrip;
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
            stops.forEach((key, value) async {
              await tripStopDaoProvider.insertTripStop(TripStop(
                  trip_id: currentTrip!.id!,
                  stop_id: value.id!,
                  name_stop: key));
            });
            Navigator.pop(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.check),
        ),
        body: Column(
          children: [
            Row(
              children: [
                const Text("Trip Name:"),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  width: 200,
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    setState(() {
                      currentTrip = Trip(
                          name: textController.text, updated: DateTime.now());
                    });

                    print(current_lng);
                  },
                ),
              ],
            ),
            TextButton(
              child: const Text(
                'Add Stop',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<DataPass>(
                  builder: (BuildContext context) {
                    return const ManageStop();
                  },
                )).then((value) => {
                      if (value != null)
                        {
                          setState(() {
                            stops[value.name] = value.stop;
                          })
                        }
                    });
              },
            ),
            // const Text("Stops for this Trip:"),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stops.length,
                itemBuilder: (context, index) => ListTile(
                    title: Text(
                        "${stops.keys.elementAt(index)}: ${stops.values.elementAt(index).address}"),
                    subtitle: const Text('Click here to edit'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute<DataPass>(
                        builder: (BuildContext context) {
                          return ManageStop(stop: stops[index]);
                        },
                      )).then((value) => {
                            if (value != null)
                              {
                                setState(() {
                                  stops[value.name] = value.stop;
                                })
                              }
                          });
                    }),
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
