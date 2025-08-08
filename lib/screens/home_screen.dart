import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'package:remixicon/remixicon.dart';
import 'chat_list_screen.dart'; // ← 이거 반드시 추가

class HomeScreen extends StatefulWidget {
  final int tabIndex;
  final void Function(int tabIndex)? onTabChange;

  const HomeScreen({super.key, this.tabIndex = 0, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTabIndex;
  final List tabs = ['추천', '모임', '구해요', '장소'];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      setState(() {
        _selectedTabIndex = widget.tabIndex;
      });
    }
  }

  // 탭 클릭시 부모에 알려줌
  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    widget.onTabChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 247, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "CC,",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(child: Container()),
                // 채팅 아이콘 (remixicon)
                IconButton(
                  icon: const Icon(Remix.chat_3_line, size: 26), // 말풍선+점3개
                  tooltip: '채팅',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 26),
                  tooltip: '알림',
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
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 상단 탭 바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => _onTabTap(index),
                    child: Column(
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
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
                          color: isSelected
                              ? Colors.cyanAccent
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),

          // 각 탭별 컨텐츠
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedTabIndex == 0) {
                  return _buildRecommendTab();
                } else if (_selectedTabIndex == 1) {
                  return const Center(child: Text("모임 탭 더미"));
                } else if (_selectedTabIndex == 2) {
                  return const Center(child: Text("구해요 탭 더미"));
                } else {
                  return const Center(child: Text("장소 탭 더미"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 추천 탭 화면 구성
  Widget _buildRecommendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          SectionTitle(
            title: "✨ 이런 모임은 어때요?",
            onMoreTap: () => _onTabTap(1), // 모임 탭으로 이동!
          ),
          const SizedBox(height: 8),

          // 모임 카드 슬라이드
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80',
                  title: "함께 성장하는 독서 모임",
                  tags: "#독서 #자기계발",
                  heartCount: 120,
                  onArrowTap: () => print("함께 성장하는 독서 모임: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "주말엔 브런치",
                  tags: "#맛집 #취향공유",
                  heartCount: 88,
                  onArrowTap: () => print("주말엔 브런치: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "토요일엔 스터디/기타 긴 이름 예시",
                  tags: "#스터디 #개발 #네트워킹",
                  heartCount: 77,
                  onArrowTap: () => print("토요일엔 스터디/기타 긴 이름 예시: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "문화 탐방 모임",
                  tags: "#전시 #문화생활",
                  heartCount: 65,
                  onArrowTap: () => print("문화 탐방 모임: 상세 준비중"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SectionTitle(
            title: "🎯 취향저격! 추천 장소",
            onMoreTap: () => _onTabTap(3), // 장소 탭으로 이동!
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1508264165352-258db2ebd59b?auto=format&fit=crop&w=8',
                  title: "별 보러 가는 언덕",
                  tags: "#자연 #밤하늘",
                  heartCount: 95,
                  onArrowTap: () => print("별 보러 가는 언덕: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const SectionTitle(title: "🔥 지금 가장 핫한 유저"),
          const SizedBox(height: 11),

          Padding(
            padding: const EdgeInsets.only(left: 26.0, right: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUser(
                  "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&q=80",
                  "제니",
                  250,
                ),
                _buildUser(
                  "https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=facearea&w=200&q=80",
                  "라이언",
                  210,
                ),
                _buildUser(
                  "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=facearea&w=200&q=80",
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

  // 카드형 콘텐츠 위젯 (모임, 장소 등)
  Widget _buildCard({
    required String image,
    required String title,
    required String tags,
    required int heartCount,
    VoidCallback? onArrowTap,
  }) {
    final tagList = tags.trim().split(RegExp(r'\s+'));

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 13, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        "5/10명",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 13,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$heartCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            right: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                tagList.length <= 2
                    ? Wrap(
                        spacing: 6,
                        children: tagList
                            .where((tag) => tag.isNotEmpty)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  tag.startsWith('#') ? tag : '#$tag',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : SizedBox(
                        height: 24,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tagList.length,
                          itemBuilder: (context, idx) {
                            final tag = tagList[idx];
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  tag.startsWith('#') ? tag : '#$tag',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onArrowTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  color: Colors.black.withOpacity(0.44),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 유저 정보 위젯 (이미지 + 이름 + 좋아요 수)
  Widget _buildUser(String imageUrl, String name, int likes) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipOval(
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 14)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
              const SizedBox(width: 2),
              Text("$likes", style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// 섹션 타이틀 위젯 (타이틀 + 더보기 버튼)
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionTitle({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Text(
              "더보기 >",
              style: TextStyle(color: const Color.fromARGB(255, 36, 36, 36)),
            ),
          ),
      ],
    );
  }
}
