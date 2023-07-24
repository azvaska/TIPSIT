import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'widgets/maps.dart';
import 'widgets/profile.dart';
import 'widgets/ranking.dart';
import 'widgets/scanQRCodeScreen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this,
        length: 4,
        initialIndex: 1,
        animationDuration: Duration(milliseconds: 200)); 
    _tabController.addListener(_handleTabSelection);
  }

  final List<Widget> _screens = [
    ScanQRCodeScreen(),
    MapWidget(),
    RankingScreen(),
    ProfileScreen()
  ];

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: TabBarView(
            controller: _tabController,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 199, 84, 84),
                boxShadow: [
                  BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
                ]),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    duration: const Duration(milliseconds: 200),
                    tabBackgroundColor: const Color.fromARGB(255, 189, 174, 43),
                    tabs: const [
                      GButton(
                        icon: Icons.qr_code_scanner,
                        text: 'Scan QR',
                      ),
                      GButton(
                        icon: Icons.map,
                        text: 'Maps',
                      ),
                      GButton(
                        icon: Icons.format_list_numbered_rtl,
                        text: 'Ranking',
                      ),
                      GButton(
                        icon: Icons.account_circle,
                        text: 'Profile',
                      ),
                    ],
                    selectedIndex: _currentIndex, // Modificato
                    onTabChange: (index) {
                      setState(() {
                        _tabController.index = index;
                      });
                    }),
              ),
            ),
          ),
        ));
  }
}
