// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'matching_screen.dart'; // 중앙 버튼용
import 'mygroup.dart';
import 'hotusers.dart'; // ★ 추가

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
  late int _selectedIndex; // 0~4 = 하단바 탭, 5 = 핫유저 숨은 페이지
  late int _homeTabIndex; // 홈 내부 탭

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialNavIndex;
    _homeTabIndex = widget.initialHomeTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final int navBarIndex = (_selectedIndex == 5) ? 0 : _selectedIndex;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0: 홈
          HomeScreen(
            tabIndex: _homeTabIndex,
            onTabChange: (idx) => setState(() => _homeTabIndex = idx),
            onOpenHotUsers: () =>
                setState(() => _selectedIndex = 5), // ★ 더보기 > 누르면 5번으로
          ),

          // 1: 내 모임
          const MyGroupScreen(),

          // 2: 매칭 (중앙 플로팅)
          const MatchingScreen(),

          // 3: 캘린더
          const CalendarScreen(),

          // 4: 프로필
          const ProfileScreen(),

          // 5: 🔥 핫한 유저(숨은 페이지) — 하단바엔 버튼 없음. 홈 강조 유지.
          const HotUsersScreen(),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navBarIndex,
        onTap: (i) {
          setState(() {
            _selectedIndex = i; // 0,1,3,4로 이동
            if (i == 0) _homeTabIndex = 0; // 홈 아이콘 → 홈 내부 탭도 "추천"
          });
        },
        onCenterTap: () => setState(() => _selectedIndex = 2), // 가운데 버튼 → 매칭
      ),
    );
  }
}
