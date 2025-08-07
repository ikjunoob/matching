import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'post_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'custom_bottom_nav_bar.dart'; // 커스텀 하단바 import

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

      // 📌 커스텀 하단 네비게이션 바 적용
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
        },
        onCenterTap: () {
          setState(() => _selectedIndex = 2); // 가운데 버튼(글쓰기) 탭
        },
      ),
    );
  }
}
