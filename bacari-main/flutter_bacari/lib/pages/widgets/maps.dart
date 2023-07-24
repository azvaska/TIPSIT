import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as MapLauncher;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../main.dart';
import '../api_provider.dart';

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late List<dynamic> markers;
  late ApiProvider apiProvider;

  @override
  void initState() {
    super.initState();
    apiProvider = Provider.of<ApiProvider>(context, listen: false);
  }

  Position _position = Position(
      latitude: 45.438759,
      longitude: 12.327145,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<List<Marker>> _getMarkers() async {
    updateLocation();

    var response = await apiProvider.makeBackendCall('bacari', null);

    if (response.statusCode == 200) {
      markers = jsonDecode(response.body) as List<dynamic>;

      return markers.map((marker) {
        return Marker(
          point: LatLng(double.parse(marker['lat'].toString()),
              double.parse(marker['lng'].toString())),
          width: 70.0,
          height: 70.0,
          builder: (context) => GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 100.0,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: Icon(Icons.location_pin, color: Colors.red)),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                marker['name'],
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if ((await MapLauncher.MapLauncher.isMapAvailable(
                                    MapLauncher.MapType.google)) ??
                                false) {
                              final availableMaps =
                                  await MapLauncher.MapLauncher.installedMaps;

                              await availableMaps.first.showDirections(
                                destination: MapLauncher.Coords(
                                    marker['lat'], marker['lng']),
                                destinationTitle: marker['name'],
                              );
                            } else {
                              throw 'Could not launch maps';
                            }
                          },
                          icon: Icon(Icons.directions),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.location_pin, color: Colors.red, size: 30.0),
          ),
        );
      }).toList();
    } else {
      throw Exception('Failed to load markers');
    }
  }

  Future<void> updateLocation() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();

      _position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 5));
      print("${_position.latitude}, ${_position.longitude}");
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Marker>>(
        future: _getMarkers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FlutterMap(
              options: MapOptions(
                center: LatLng(_position.latitude, _position.longitude),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: snapshot.data!,
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
