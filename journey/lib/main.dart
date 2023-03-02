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

class MyApp extends StatefulWidget {
  const MyApp(this.database, {super.key});
  final AppDatabase database;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // check_permission();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripStopProvider(widget.database),
      child: const MaterialApp(
        title: 'My App',
        home: TripList(),
      ),
    );
  }
}
