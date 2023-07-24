import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../api_provider.dart';

class ScanQRCodeScreen extends StatefulWidget {
  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String qrCode = '';
  late ApiProvider apiProvider;

  @override
  void initState() {
    super.initState();
    apiProvider = Provider.of<ApiProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                height: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      var bacaro =
          await apiProvider.makeBackendCall('bacaro/${scanData.code!}', null);

      var responseBacaro = jsonDecode(bacaro.body) as Map<String, dynamic>;

      if (bacaro.statusCode == 200) {
        try {
          LocationPermission permission;
          permission = await Geolocator.requestPermission();

          var userPosition = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high)
              .timeout(const Duration(seconds: 5));
          print("${userPosition.latitude}, ${userPosition.longitude}");

          double distanceInMeters = await Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              double.parse(responseBacaro['lat'].toString()),
              double.parse(responseBacaro['lng'].toString()));

          if (distanceInMeters > 100) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text("You aren't near the bacaro!"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                );
              },
            );
            controller.resumeCamera();
            return;
          } else {
            var response = await apiProvider.makeBackendCall(
                'add_score/${scanData.code!}', null);

            if (response.statusCode == 200) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Added score'),
                    content: const Text(
                        "Work is the curse of the drinking classes!"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text("Error: ${response.body}"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        } catch (e) {
          debugPrint('Error: $e');
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(bacaro.body),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      }

      controller.resumeCamera();
    });
  }
}
