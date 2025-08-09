import 'package:flutter/material.dart';
import 'home_screen.dart'; // 홈(추천) 화면
import 'group_screen.dart'; // 모임 화면
import 'post_screen.dart'; // 글쓰기 화면
import 'calendar_screen.dart'; // 캘린더 화면
import 'profile_screen.dart'; // 프로필(마이페이지) 화면
import 'custom_bottom_nav_bar.dart'; // 커스텀 하단 네비게이션바

// -------------------- MainScreen: 앱 전체의 메인/탭/네비게이션 컨테이너 --------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// -------------------- MainScreen의 State (하단 탭, 상단 홈탭 상태/화면전환) --------------------
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex =
      0; // 하단 네비게이션바에서 현재 선택된 아이콘의 인덱스 (0:홈, 1:모임, 2:글쓰기, 3:캘린더, 4:프로필, -1:홈 비활성화)
  int _homeTabIndex = 0; // 홈(추천)화면의 상단 탭 인덱스 (0:추천, 1:모임, 2:구해요, 3:장소)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 하단 네비게이션바와 Body가 겹치는 효과(그림자, 둥근 효과 등)
      // -------------------- 중앙 컨텐츠: 현재 탭에 맞는 페이지 반환 --------------------
      body: _getPage(_selectedIndex, _homeTabIndex),
      // -------------------- 하단 네비게이션 바 --------------------
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex, // 현재 선택된 인덱스 전달 (홈,모임,글쓰기,캘린더,프로필)
        onTap: (i) {
          // [하단 네비게이션바 클릭시 실행]
          if (i == 0) {
            // 홈(추천) 아이콘 클릭시 → 홈+추천탭으로 이동
            setState(() {
              _selectedIndex = 0;
              _homeTabIndex = 0; // 홈화면의 상단 탭도 '추천'으로 변경
            });
          } else {
            // 그 외(모임, 글쓰기, 캘린더, 프로필) 클릭시 해당 탭으로 이동
            setState(() {
              _selectedIndex = i;
            });
          }
        },
        // [중앙 글쓰기 버튼(+) 클릭시 실행]
        onCenterTap: () {
          setState(() => _selectedIndex = 2); // 글쓰기(2)로 이동
        },
      ),
    );
  }

  // -------------------- 실제로 각 네비게이션/탭별 보여줄 화면을 반환 --------------------
  Widget _getPage(int navIndex, int homeTabIndex) {
    if (navIndex == 0 || navIndex == -1) {
      // [홈(추천)] 또는 홈 내의 다른 탭을 선택했을 때
      // tabIndex: 상단 탭(추천/모임/구해요/장소) 지정
      return HomeScreen(
        tabIndex: homeTabIndex,
        // [상단 탭 변경시 콜백] → 상단탭 클릭 시 하단바 상태까지 맞춰서 관리
        onTabChange: (int idx) {
          setState(() {
            _homeTabIndex = idx;
            // 추천(0) 탭이면 홈버튼(0) 활성화, 나머지 탭이면 홈버튼 비활성(-1)
            _selectedIndex = (idx == 0) ? 0 : -1;
          });
        },
      );
    }
    // [홈이 아닐 때] 각 네비게이션 인덱스별 다른 화면 반환
    switch (navIndex) {
      case 1:
        return const GroupScreen(); // 모임 화면
      case 2:
        return const PostScreen(); // 글쓰기 화면
      case 3:
        return const CalendarScreen(); // 캘린더 화면
      case 4:
        return const ProfileScreen(); // 프로필(마이페이지) 화면
      default:
        return const HomeScreen(); // 예외: 기본 홈화면
    }
  }
}
