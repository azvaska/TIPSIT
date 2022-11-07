import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:timer_dp/Screens/timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Widget> screens = [
  const TimerPage(
    timerDuration: Duration(minutes: 1),
  )
];

class _HomePageState extends State<HomePage> {
  int _currentScreenIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 20,
        selectedIconTheme:
            const IconThemeData(color: Colors.amberAccent, size: 40),
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _currentScreenIndex,
        onTap: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_bottom_sharp),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Stopwach',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text("sd"),
      ),
      body: Center(child: screens[_currentScreenIndex]),
    );
  }
}
