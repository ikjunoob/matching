import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'group_screen.dart';
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
  int _selectedIndex = 0;   // 하단바 index, -1은 "홈(추천) 선택X"
  int _homeTabIndex = 0;    // 상단탭 index (0:추천, 1:모임, 2:구해요, 3:장소)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _getPage(_selectedIndex, _homeTabIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex, // 0~4 or -1
        onTap: (i) {
          if (i == 0) {
            setState(() {
              _selectedIndex = 0;
              _homeTabIndex = 0; // 추천탭으로 이동
            });
          } else {
            setState(() {
              _selectedIndex = i;
            });
          }
        },
        onCenterTap: () {
          setState(() => _selectedIndex = 2); // 글쓰기
        },
      ),
    );
  }

  Widget _getPage(int navIndex, int homeTabIndex) {
    if (navIndex == 0 || navIndex == -1) {
      // 홈 화면
      return HomeScreen(
        tabIndex: homeTabIndex,
        onTabChange: (int idx) {
          setState(() {
            _homeTabIndex = idx;
            // 추천(0) -> 홈(0) 활성화, 나머지 -> 홈(-1) 원상태
            _selectedIndex = (idx == 0) ? 0 : -1;
          });
        },
      );
    }
    switch (navIndex) {
      case 1:
        return const GroupScreen();
      case 2:
        return const PostScreen();
      case 3:
        return const CalendarScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
