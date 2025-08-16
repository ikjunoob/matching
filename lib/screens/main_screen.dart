import 'package:flutter/material.dart';
import 'home_screen.dart'; // 홈(추천) 화면
import 'group_screen.dart'; // 모임 화면
import 'calendar_screen.dart'; // 캘린더 화면
import 'profile_screen.dart'; // 프로필(마이페이지) 화면
import 'custom_bottom_nav_bar.dart'; // 커스텀 하단 네비게이션바
import 'matching_screen.dart';

/// -------------------- MainScreen: 앱 전체의 메인/탭/네비게이션 컨테이너 --------------------
class MainScreen extends StatefulWidget {
  /// initialNavIndex: 하단 네비게이션 초기 인덱스 (0:홈, 1:모임, 2:매칭, 3:캘린더, 4:프로필)
  /// initialHomeTabIndex: 홈 상단 탭 초기 인덱스 (0:추천, 1:모임, 2:구해요, 3:장소)
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

/// -------------------- MainScreen의 State (하단 탭, 상단 홈탭 상태/화면전환) --------------------
class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex; // 현재 하단 네비 인덱스
  late int _homeTabIndex; // 홈 상단 탭 인덱스

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialNavIndex;
    _homeTabIndex = widget.initialHomeTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 하단 네비와 컨텐츠 겹침 효과
      body: _getPage(_selectedIndex, _homeTabIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 0) {
            // 홈(추천) 아이콘 클릭시 → 홈 + 추천탭으로 이동
            setState(() {
              _selectedIndex = 0;
              _homeTabIndex = 0;
            });
          } else {
            // 그 외(모임, 매칭, 캘린더, 프로필)
            setState(() {
              _selectedIndex = i;
            });
          }
        },
        onCenterTap: () {
          setState(() => _selectedIndex = 2); // 중앙 매칭 버튼
        },
      ),
    );
  }

  /// -------------------- 각 네비/탭별 화면 반환 --------------------
  Widget _getPage(int navIndex, int homeTabIndex) {
    // 홈(추천) 또는 홈 내 다른 탭
    if (navIndex == 0 || navIndex == -1) {
      return HomeScreen(
        tabIndex: homeTabIndex,
        onTabChange: (int idx) {
          setState(() {
            _homeTabIndex = idx;
            // 추천(0) 탭이면 홈버튼(0) 활성화, 나머지 탭이면 홈버튼 비활성(-1)
            _selectedIndex = (idx == 0) ? 0 : -1;
          });
        },
      );
    }

    // 홈이 아닐 때
    switch (navIndex) {
      case 1:
        return const GroupScreen(); // 모임
      case 2:
        return const MatchingScreen(); // 매칭
      case 3:
        return const CalendarScreen(); // 캘린더
      case 4:
        return const ProfileScreen(); // 프로필
      default:
        return const HomeScreen(); // 예외: 기본 홈
    }
  }
}
