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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          BottomNavigationBar(
            currentIndex: _selectedIndex > 2
                ? _selectedIndex - 1
                : _selectedIndex,
            onTap: (index) {
              if (index == 2) return;
              _onItemTapped(index > 1 ? index + 1 : index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: '',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
            selectedItemColor: Color(0xFF000000),
            unselectedItemColor: Color(0xFF9CA3AF),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
          ),
          Positioned(
            bottom: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () => _onItemTapped(2),
              child: const Icon(Icons.podcasts, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
