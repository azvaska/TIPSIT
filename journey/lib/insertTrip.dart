import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:journey/insertMap.dart';
import 'package:journey/insertStop.dart';
import 'package:journey/tripprovider.dart';
import 'package:provider/provider.dart';

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
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
                child: Column(
              children: [
                const Text("Trip Name:"),
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
                      child: Container(
                        width: 250,
                        child: TextField(
                          controller: textController,
                          maxLines: null,
                        ),
                      ),
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
                        currentTrip!.id =
                            await tripStopDaoProvider.insertTrip(currentTrip!);

                        stops.forEach((key, value) async {
                          value.id =
                              await tripStopDaoProvider.insertStop(value);
                          await tripStopDaoProvider.insertTripStop(TripStop(
                              trip_id: currentTrip!.id!,
                              stop_id: value.id!,
                              name_stop: key));
                        });
                        Navigator.pop(context);

                        print(current_lng);
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
            Expanded(
              child: ReorderableListView(
                shrinkWrap: true,
                onReorder: (int oldIndex, int newIndex) {
                  var key = stops.keys.elementAt(oldIndex);
                  var item = {key: stops.remove(key)!};
                  var i = 0;
                  var newMap = LinkedHashMap<String, Stop>();
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
                            setState(() {
                              stops.remove(stops.keys.elementAt(index));
                            });

                            // Then show a snackbar.
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    '${stops.keys.elementAt(index)} dismissed')));
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
              key: Key(stops.hashCode.toString() + stops.length.toString()),
            )
          ],
        ),
      ),
    );
  }
}
