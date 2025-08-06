// home_screen.dart
import 'package:flutter/material.dart';
import 'notification_screen.dart';

// 홈 화면 위젯 (탭 구조 포함)
// 홈 컨텐츠, 탭 전환(추천,모임,구해요,장소), 상단 바 포함
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  int _selectedTabIndex = 0; // 현재 선택된 탭 인덱스
  final List tabs = ['추천', '모임', '구해요', '장소']; // 탭 이름 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // 전체 배경 색
      // ✅ 완전 왼쪽 끝 정렬 Custom AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10), // 진짜로 완전 왼쪽 끝!
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
                // (원하면 CAMPUS CONNECT 텍스트 여기 추가)
                Expanded(child: Container()),
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
                final isSelected = _selectedTabIndex == index; // 현재 탭인지 여부
                return Padding(
                  padding: const EdgeInsets.only(right: 20), // 탭 간 간격
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = index),
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
                          duration: const Duration(
                            milliseconds: 200,
                          ), // 밑줄 애니메이션
                          height: 2,
                          width: isSelected ? 24 : 0, // 선택된 탭만 밑줄 표시
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

          // 각 탭별 컨텐츠를 바로 보여줌 (슬라이드X)
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedTabIndex == 0) {
                  return _buildRecommendTab(); // 추천 탭
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "이런 모임은 어때요?" 섹션
          SectionTitle(
            title: "✨ 이런 모임은 어때요?",
            onMoreTap: () => setState(() => _selectedTabIndex = 1), // 모임 탭으로 이동
          ),
          const SizedBox(height: 8),

          // 모임 카드 슬라이드 (왼쪽 정렬)
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
                  subtitle: "독서, 자기계발",
                  heartCount: 120,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "주말엔 브런치",
                  subtitle: "맛집, 취향공유",
                  heartCount: 88,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "토요일엔 스터디/기타 긴 이름 예시",
                  subtitle: "스터디, 개발, 네트워킹",
                  heartCount: 77,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "문화 탐방 모임",
                  subtitle: "전시, 문화생활",
                  heartCount: 65,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // "추천 장소" 섹션
          SectionTitle(
            title: "🎯 취향저격! 추천 장소",
            onMoreTap: () => setState(() => _selectedTabIndex = 3), // 장소 탭으로 이동
          ),
          const SizedBox(height: 8),

          // 장소 카드 슬라이드 (왼쪽 정렬)
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
                  subtitle: "자연, 밤하늘",
                  heartCount: 95,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  subtitle: "공부하기 좋은 카페",
                  heartCount: 76,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  subtitle: "공부하기 좋은 카페",
                  heartCount: 76,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  subtitle: "공부하기 좋은 카페",
                  heartCount: 76,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionTitle(title: "🔥 지금 가장 핫한 유저"),
          const SizedBox(height: 11),

          // 유저 카드 영역 - spaceBetween 간격!
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  // 카드형 콘텐츠 위젯 (모임, 장소 등)
  Widget _buildCard({
    required String image,
    required String title,
    required String subtitle,
    required int heartCount,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          // 하단 텍스트 정보 (반투명 라운드 박스)
          Positioned(
            left: 8,
            bottom: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: Colors.black.withOpacity(0.44),
                constraints: const BoxConstraints(
                  maxWidth: 132, // 카드 width - margin 감안 (160-2*12 등)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // 🔵 크기 더 줄임
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "#$subtitle",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10, // 🔵 더 작게
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 상단 인원수 + 하트 (반투명 라운드 박스)
          Positioned(
            top: 8,
            left: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black.withOpacity(0.44),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, size: 16, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      "5/10명",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(width: 11),
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    Text(
                      "$heartCount",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 우측 하단 화살표 (반투명 라운드 박스)
          Positioned(
            bottom: 8,
            right: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                color: Colors.black.withOpacity(0.44),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white,
                ), // 아이콘도 소폭 줄임
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
          CircleAvatar(radius: 35, backgroundImage: NetworkImage(imageUrl)),
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
  final String title; // 제목 텍스트
  final VoidCallback? onMoreTap; // 더보기 클릭 이벤트

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
            child: Text("더보기 >", style: TextStyle(color: Colors.grey[600])),
          ),
      ],
    );
  }
}
