import 'package:flutter/material.dart';
import 'package:in_stock_tracker/account/profile.dart';
import 'package:in_stock_tracker/watchlist/watchlist.dart';

class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainView();
}

class _MainView extends State<MainView> {
  int index = 0;
  final screens = [const Watchlist(), const Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.red,
          iconSize: 24,
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'In-Stock Tracker',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 40,
        currentIndex: index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        onTap: (int index) {
          setState(() {
            this.index = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
