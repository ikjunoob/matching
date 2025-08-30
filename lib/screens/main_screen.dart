// main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'group_tab_screen.dart'; // ✅ 이 파일에서 노출되는 클래스는 GroupTabScreen
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'custom_bottom_nav_bar.dart';
import 'matching_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    this.initialNavIndex = 0,
    this.initialHomeTabIndex = 0,
  });

  final int initialNavIndex;
  final int initialHomeTabIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late int _homeTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialNavIndex;
    _homeTabIndex = widget.initialHomeTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _getPage(_selectedIndex, _homeTabIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 0) {
            setState(() {
              _selectedIndex = 0;
              _homeTabIndex = 0;
            });
          } else {
            setState(() {
              _selectedIndex = i;
            });
          }
        },
        onCenterTap: () => setState(() => _selectedIndex = 2),
      ),
    );
  }

  Widget _getPage(int navIndex, int homeTabIndex) {
    if (navIndex == 0 || navIndex == -1) {
      return HomeScreen(
        tabIndex: homeTabIndex,
        onTabChange: (idx) {
          setState(() {
            _homeTabIndex = idx;
            _selectedIndex = (idx == 0) ? 0 : -1;
          });
        },
      );
    }

    switch (navIndex) {
      case 1:
        return const GroupTabScreen(); // ✅ 여기!
      case 2:
        return const MatchingScreen();
      case 3:
        return const CalendarScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
