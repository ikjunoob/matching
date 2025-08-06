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
          SectionTitle(
            title: "✨ 이런 모임은 어때요?",
            onMoreTap: () => setState(() => _selectedTabIndex = 1),
          ),
          const SizedBox(height: 8),

          // 모임 카드 슬라이드 (전부 print 메시지)
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

          const SizedBox(height: 24),
          const SectionTitle(title: "🔥 지금 가장 핫한 유저"),
          const SizedBox(height: 11),

          // 유저 카드 영역 - spaceBetween 간격!
          Padding(
            padding: const EdgeInsets.only(
              left: 26.0,
              right: 14.0,
            ), // ← 왼쪽이 더 넓음
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUser(
                  "https://randomuser.me/api/portraits/women/44.jpg", // 여성
                  "제니",
                  250,
                ),
                _buildUser(
                  "https://randomuser.me/api/portraits/men/36.jpg", // 남성
                  "라이언",
                  210,
                ),
                _buildUser(
                  "https://randomuser.me/api/portraits/women/68.jpg", // 여성
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
    required String tags, // 예: "#스터디 #개발 #네트워킹"
    required int heartCount,
    VoidCallback? onArrowTap,
  }) {
    // 공백 기준 분리
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
          // Gradient overlay
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
          // 상단 인원수 + 하트 (각각 반투명)
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
          // 하단: 타이틀(반투명 X) + 태그(각각 반투명)
          Positioned(
            left: 10,
            bottom: 10,
            right: 34, // ← 화살표와 겹치지 않도록 right값 살짝 줌
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀
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
                // 태그 슬라이드 or wrap
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
                        // 태그가 3개 이상이면 가로 슬라이드
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
          // 우측 하단 화살표 (반투명, 탭 가능하게)
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onArrowTap, // ← 여기에 상세 페이지 이동, 혹은 null
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
