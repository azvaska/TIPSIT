import 'package:flutter/material.dart';
import 'package:timer_dp/Screens/timer.dart';
import 'package:timer_dp/Screens/timerpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Widget> screens = [
  const TimerScreen(),
  Column(children: [
    Expanded(
      child: TimerPage(
        isTimer: false,
        cancelTimer: () {},
      ),
    ),
  ]),
];

class _HomePageState extends State<HomePage> {
  int _currentScreenIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 15,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
        selectedItemColor: Colors.white,
        // unselectedIconTheme: const IconThemeData(color: Colors.white, size: 15),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 37, 76, 182),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _currentScreenIndex,
        onTap: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(color: Colors.white, Icons.hourglass_bottom_sharp),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(color: Colors.white, Icons.timer),
            label: 'Stopwach',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 51, 147),
        title: const Text("Welcome to the Timer App"),
      ),
      body: Container(
          color: const Color.fromARGB(255, 144, 167, 229),
          child: Center(child: screens[_currentScreenIndex])),
    );
  }
}
