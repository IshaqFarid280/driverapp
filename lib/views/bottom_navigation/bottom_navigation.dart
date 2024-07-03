import 'package:driverapp/views/book_a_ride_screen/book_ride_screen.dart';
import 'package:driverapp/views/notification/notification_screen.dart';
import 'package:driverapp/views/scheduled_screen/scheduled_screen.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/views/profile_Screen/profile_screen.dart';

import '../home_screen/mapscreen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final String userId;
  BottomNavigationScreen({required this.userId});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}
class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      HomeScreen(userId: widget.userId),
      ScheduledScreen(),
      BookRideScreen(),
      NotificationScreen(),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Taxi App'),
      // ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black26,
        currentIndex: _currentIndex,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        selectedLabelStyle: TextStyle(
          color: Colors.black
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey
        ),
        selectedIconTheme: IconThemeData(
          color: Colors.black
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.grey
        ),
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(

            icon: Icon(Icons.dashboard),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Book a Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
