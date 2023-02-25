import 'package:flutter/material.dart';
import 'package:journey/Triplist.dart';
import 'package:journey/db.dart';
import 'package:journey/tripprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the database instance by awaiting the result of databaseBuilder
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
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
