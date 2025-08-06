import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'post_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ChatScreen(),
    PostScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.group,
                    color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(1),
                ),
                const SizedBox(width: 40), // for spacing around FAB
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: _selectedIndex == 3 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(3),
                ),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: _selectedIndex == 4 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => _onItemTapped(2),
        child: const Icon(Icons.podcasts, color: Colors.black),
      ),
    );
  }
}
