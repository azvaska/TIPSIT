import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:journey/insertMap.dart';
import 'package:journey/insertStop.dart';
import 'package:journey/tripprovider.dart';
import 'package:provider/provider.dart';
import 'model/trip.dart';

class InsertTrip extends StatefulWidget {
  const InsertTrip({super.key, this.trip, this.stops});
  final Trip? trip;
  final LinkedHashMap<String, Stop>? stops;
  @override
  State<InsertTrip> createState() => _InsertTripState();
}

class _InsertTripState extends State<InsertTrip> {
  LinkedHashMap<String, Stop> stops = LinkedHashMap<String, Stop>();
  Trip? currentTrip;
  late TripStopProvider tripStopDaoProvider;
  TextEditingController textController = TextEditingController();
  final double precision = 0.0001;
  @override
  initState() {
    super.initState();
    if (widget.trip != null && widget.stops != null) {
      currentTrip = widget.trip;
      textController.text = currentTrip!.name;
      stops = LinkedHashMap<String, Stop>.from(widget.stops!);
    }
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
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
                child: Column(
              children: [
                const Text(
                  "Trip Name:",
                  style: TextStyle(fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.abc,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (currentTrip == null) {
                            currentTrip = Trip(
                                name: textController.text,
                                updated: DateTime.now());
                            // currentTrip!.id = tripStopDaoProvider.insertTrip(currentTrip!);
                          } else {
                            currentTrip!.name = textController.text;
                            currentTrip!.updated = DateTime.now();
                            // tripStopDaoProvider.updateTrip(currentTrip!);
                          }
                        });
                      },
                    ),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: textController,
                          maxLines: null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          if (currentTrip == null) {
                            currentTrip = Trip(
                                name: textController.text,
                                updated: DateTime.now());
                            // currentTrip!.id = tripStopDaoProvider.insertTrip(currentTrip!);
                          } else {
                            currentTrip!.name = textController.text;
                            currentTrip!.updated = DateTime.now();
                            // tripStopDaoProvider.updateTrip(currentTrip!);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.save,
                        size: 35,
                      ),
                      onPressed: () async {
                        if (currentTrip == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Please insert a name for the trip before saving")));
                          return;
                        }
                        if (widget.trip != null) {
                          await tripStopDaoProvider.updateTrip(currentTrip!);
                          if (widget.stops != null) {
                            // remove all the saved stops that are not in the new list
                            List<TripStop> output = await tripStopDaoProvider
                                .getTripStopForTrip(currentTrip!.id!);
                            // for (var element in widget.stops!.entries) {
                            //   if (!stops.values
                            //       .contains(element.value)) {
                            //   TripStop? sus = await tripStopDaoProvider
                            //       .getTripStopForStop(element.value.id!);
                            //   output.add(sus!);
                            // }
                            for (var element in output) {
                              await tripStopDaoProvider.deleteTripStop(element);
                            }
                          }
                        } else {
                          currentTrip!.id = await tripStopDaoProvider
                              .insertTrip(currentTrip!);
                        }
                        //insert all the stops with the trip id
                        for (var i = 0; i < stops.length; i++) {
                          var key = stops.keys.elementAt(i);
                          Stop stop = stops.values.elementAt(i);

                          if (stop.id != null) {
                            await tripStopDaoProvider.updateStop(stop);
                            //tofix
                            await tripStopDaoProvider.insertTripStop(TripStop(
                                trip_id: currentTrip!.id!,
                                stop_id: stop.id!,
                                name_stop: key));
                            continue;
                          }
                          //+- 0.0001 is about 13 meters in all directions
                          List<Stop> possibleStops = await tripStopDaoProvider
                              .getAllStopsNear(stop.lat, stop.lng, precision);

                          if (possibleStops.isNotEmpty) {
                            stop = possibleStops.first;
                          } else {
                            stop.id =
                                await tripStopDaoProvider.insertStop(stop);
                          }
                          await tripStopDaoProvider.insertTripStop(TripStop(
                              trip_id: currentTrip!.id!,
                              stop_id: stop.id!,
                              name_stop: key));
                        }
                        ;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, currentTrip);
                      },
                    ),
                  ],
                ),
              ],
            )),
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
                )).then((value) {
                  if (value != null) {
                    setState(() {
                      stops[value.name] = value.stop;
                    });
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              },
            ),
            // const Text("Stops for this Trip:"),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Stops:",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: ReorderableListView(
                shrinkWrap: true,
                onReorder: (int oldIndex, int newIndex) {
                  var key = stops.keys.elementAt(oldIndex);
                  var item = {key: stops.remove(key)!};
                  var i = 0;
                  // ignore: prefer_collection_literals
                  LinkedHashMap<String, Stop> newMap = LinkedHashMap();
                  stops.forEach((key, value) {
                    if (i == newIndex) {
                      newMap.addAll(item);
                    }
                    newMap[key] = value;
                    i++;
                  });
                  if (i <= newIndex) {
                    newMap.addAll(item);
                  }
                  setState(() {
                    stops = newMap;
                  });
                },
                children: List.generate(
                    stops.length,
                    (index) => Dismissible(
                          onDismissed: (direction) {
                            // Remove the item from the data source.
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    '${stops.keys.elementAt(index)} deleted')));
                            setState(() {
                              stops.remove(stops.keys.elementAt(index));
                            });

                            // Then show a snackbar.
                          },
                          key: Key(stops.keys.elementAt(index)),
                          background: Container(color: Colors.red),
                          child: ListTile(
                              title: Text(
                                  "${stops.keys.elementAt(index)}: ${stops.values.elementAt(index).address}"),
                              subtitle: const Text('Click here to edit'),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute<DataPass>(
                                  builder: (BuildContext context) {
                                    return ManageStop(
                                      base_name: stops.keys.elementAt(index),
                                      stop: stops.values.elementAt(index),
                                    );
                                  },
                                )).then((value) {
                                  if (value != null) {
                                    stops.remove(stops.keys.elementAt(index));
                                    setState(() {
                                      stops[value.name] = value.stop;
                                    });
                                  }
                                });
                              }),
                        )),
              ),
            ),
            InsertMap(
              stopList: stops,
              key: Key(stops.hashCode.toString() +
                  stops.length.toString() +
                  stops.values.hashCode.toString()),
            )
          ],
        ),
      ),
    );
  }
}
