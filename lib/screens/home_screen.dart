import 'package:flutter/material.dart';
import 'notification_screen.dart';

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
        actions: [
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
          const SizedBox(width: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Column(
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSelected ? 24 : 0,
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
                  image:
                      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80',
                  title: "함께 성장하는 독서 모임",
                  subtitle: "독서, 자기계발",
                  heartCount: 120,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "주말엔 브런치",
                  subtitle: "맛집, 취향공유",
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
                  image:
                      'https://images.unsplash.com/photo-1508264165352-258db2ebd59b?auto=format&fit=crop&w=600&q=8',
                  title: "별 보러 가는 언덕",
                  subtitle: "자연, 밤하늘",
                  heartCount: 95,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1507914372336-5d8f0c006f0c?auto=format&fit=crop&w=600&q=80',
                  title: "조용한 카페",
                  subtitle: "공부하기 좋은 카페",
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUser("https://i.pravatar.cc/150?img=1", "제니", 250),
                _buildUser("https://i.pravatar.cc/150?img=2", "라이언", 210),
                _buildUser("https://i.pravatar.cc/150?img=3", "클로이", 180),
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
      height: 160,
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
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$heartCount",
                  style: const TextStyle(color: Colors.white),
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
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(height: 4),
        Text(name),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
            const SizedBox(width: 2),
            Text("$likes"),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("더보기 >", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
