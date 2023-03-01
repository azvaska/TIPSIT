import 'package:flutter/material.dart';
import 'package:journey/Triplist.dart';
import 'package:journey/db.dart';
import 'package:journey/tripprovider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the database instance by awaiting the result of databaseBuilder
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  check_permission();

  runApp(MyApp(database));
}

void check_permission() async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    status = await Permission.location.request();
    if (status.isDenied) {
      await openAppSettings();
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    check_permission();
    return ChangeNotifierProvider(
      create: (_) => TripStopProvider(database),
      child: const MaterialApp(
        title: 'My App',
        home: TripList(),
      ),
    );
  }
}

class MyHomePage {}
