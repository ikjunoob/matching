import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'calendar_screen.dart'; // CalendarScreen import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final List<String> tabs = ['추천', '모임', '구해요', '장소'];

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildRecommendTab();
      case 1:
        return const Center(child: Text("모임 탭 더미"));
      case 2:
        return const Center(child: Text("구해요 탭 더미"));
      case 3:
        return const Center(child: Text("장소 탭 더미"));
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Row(
          children: [
            Text(
              "CC",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
            ),
            SizedBox(width: 4),
            Text(
              "CAMPUS CONNECT",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // 채팅 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Column(
                    children: [
                      Text(
                        tabs.elementAt(index),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSelected ? 18 : 0,
                        color: isSelected ? Colors.cyan : Colors.transparent,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildTabContent(_selectedTabIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            }
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: '모임',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "✨ 이런 모임은 어때요?"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  image: 'https://source.unsplash.com/600x400/?books',
                  title: "함께 성장하는 독서 모임",
                  subtitle: "독서, 자기계발",
                  heartCount: 120,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCard(
                  image: 'https://source.unsplash.com/600x400/?brunch',
                  title: "주말엔 브런치!",
                  subtitle: "#맛집 #브런치",
                  heartCount: 88,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: "🎯 취향저격! 추천 장소"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  image: 'https://source.unsplash.com/600x400/?stars',
                  title: "별 보러 가는 언덕",
                  subtitle: "#자연 #밤하늘",
                  heartCount: 95,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCard(
                  image: 'https://source.unsplash.com/600x400/?cafe',
                  title: "조용한 카페",
                  subtitle: "#공부하기 좋은 #카페",
                  heartCount: 76,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: "🔥 지금 가장 핫한 유저"),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUser(
                  "https://randomuser.me/api/portraits/women/1.jpg",
                  "제니",
                  250,
                ),
                _buildUser(
                  "https://randomuser.me/api/portraits/men/2.jpg",
                  "라이언",
                  210,
                ),
                _buildUser(
                  "https://randomuser.me/api/portraits/women/3.jpg",
                  "클로이",
                  180,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String image,
    required String title,
    required String subtitle,
    required int heartCount,
  }) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  "$heartCount",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUser(String imageUrl, String name, int likes) {
    return Column(
      children: [
        CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.redAccent, size: 12),
            const SizedBox(width: 2),
            Text("$likes", style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("더보기 >", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}