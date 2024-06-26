import 'package:flutter/material.dart';
import 'package:eco_swap/view/main_pages/HomePage.dart';
import 'package:eco_swap/view/main_pages/SavedAdsPage.dart';
import 'package:eco_swap/view/main_pages/LoadAdPage.dart';
import 'package:eco_swap/view/main_pages/ChatsPage.dart';
import 'package:eco_swap/view/main_pages/ProfilePage.dart';

class NavigationPage extends StatefulWidget {
  final VoidCallback logoutCallback;

  const NavigationPage({Key? key, required this.logoutCallback}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SavedAdsPage(),
    LoadAdPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      backgroundColor: colorScheme.primary,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Load',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

}
