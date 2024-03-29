import 'package:flutter/material.dart';
import 'package:timer_dp/Homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  //home page with navigator flutter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clock App',
        theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 37, 76, 182)),
              ),
            )),
        home: const HomePage());
  }
}
