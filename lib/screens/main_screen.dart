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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 2
            ? _selectedIndex - 1
            : _selectedIndex == 2
            ? 0
            : _selectedIndex,
        onTap: (index) {
          if (index == 2) return; // 중앙 FAB는 따로 처리
          _onItemTapped(index > 1 ? index + 1 : index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
        selectedItemColor: Color(0xFF000000),
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
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
