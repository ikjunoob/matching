// main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'post_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

// 하단 바 및 전체 탭 구조를 관리하는 메인 화면
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 하단 탭 인덱스

  // 각 탭에 해당하는 페이지 위젯 리스트
  final List<Widget> _pages = const [
    HomeScreen(), // 0번 탭: 홈
    ChatScreen(), // 1번 탭: 채팅
    PostScreen(), // 2번 탭: 글쓰기 (FAB)
    CalendarScreen(), // 3번 탭: 캘린더
    ProfileScreen(), // 4번 탭: 프로필
  ];

  // 탭 클릭 시 인덱스를 업데이트
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 하단 영역이 투명하게 FAB 뒤로 연장됨
      body: _pages[_selectedIndex], // 현재 선택된 탭의 화면 보여줌
      // 하단 바 영역
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // 가운데 notch
        notchMargin: 8, // notch 여백
        color: const Color(0xFFF2F2F2), // 연한 회색 배경
        elevation: 5,
        child: Container(
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SizedBox(
            height: 56, // 내부 아이콘 버튼 높이
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 균등 배치
              children: [
                // 홈 아이콘
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0
                        ? Colors.black
                        : Colors.grey, // 선택 여부에 따라 색상 변경
                  ),
                  onPressed: () => _onItemTapped(0),
                ),

                // 채팅 아이콘
                IconButton(
                  icon: Icon(
                    Icons.group,
                    color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(1),
                ),

                const SizedBox(width: 40), // 가운데 FAB 공간 확보
                // 캘린더 아이콘
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: _selectedIndex == 3 ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _onItemTapped(3),
                ),

                // 프로필 아이콘
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

      // 중앙 FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70, // FAB 크기 설정
        height: 70,
        child: FloatingActionButton(
          backgroundColor: Colors.cyanAccent, // 배경 색
          shape: const CircleBorder(), // 원형 모양
          elevation: 4, // 그림자 깊이
          onPressed: () => _onItemTapped(2), // 글쓰기 탭으로 이동
          child: const Icon(
            Icons.podcasts,
            color: Colors.black,
            size: 30,
          ), // 아이콘
        ),
      ),
    );
  }
}
