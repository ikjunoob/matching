import 'package:flutter/material.dart';
import 'post_screen.dart'; // PostScreen을 import

// '구해요' 탭을 구성하는 StatefulWidget
class AskForScreen extends StatefulWidget {
  const AskForScreen({super.key});

  @override
  State<AskForScreen> createState() => _AskForScreenState();
}

class _AskForScreenState extends State<AskForScreen> {
  String _selectedSort = '최신순'; // 정렬 기준
  String _selectedCategory = '전체'; // 선택된 카테고리
  final List<String> _categories = [
    '전체',
    '스터디',
    '재능공유',
    '물품대여',
    '운동메이트',
  ]; // 임의의 카테고리

  // 예시 데이터 리스트
  final List<Map<String, dynamic>> _posts = [
    {
      'image':
          'https://images.unsplash.com/photo-1541817105318-7b950942e6f4?q=80&w=3270&auto=format&fit=crop',
      'title': '운동 메이트 구해요 (헬스)',
      'tags': ['운동', '헬스', '메이트'],
      'comments': 3,
      'views': 52,
      'likes': 71,
      'category': '운동메이트',
      'isLiked': true,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1549419131-7e8c33a92543?q=80&w=3270&auto=format&fit=crop',
      'title': '중고 전공서적 판매합니다',
      'tags': ['중고거래', '전공서적'],
      'comments': 7,
      'views': 136,
      'likes': 79,
      'category': '물품대여',
      'isLiked': false,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1517457210943-41a4a40d6c9f?q=80&w=3270&auto=format&fit=crop',
      'title': '같이 점심 먹을 사람 구해요!',
      'tags': ['점심', '맛집', '같이먹어요'],
      'comments': 17,
      'views': 237,
      'likes': 160,
      'category': '맛집',
      'isLiked': false,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1629906660132-7206b02660ae?q=80&w=3270&auto=format&fit=crop',
      'title': '아이패드 충전기 빌려주실 분?',
      'tags': ['물품공유', '아이패드', '충전기'],
      'comments': 5,
      'views': 150,
      'likes': 123,
      'category': '물품대여',
      'isLiked': false,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1522204532297-c205391a6245?q=80&w=3270&auto=format&fit=crop',
      'title': '공모전 팀원 모집합니다 (기획/디자인)',
      'tags': ['팀원모집', '공모전', '기획', '디자인'],
      'comments': 8,
      'views': 266,
      'likes': 26,
      'category': '스터디',
      'isLiked': false,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      _posts[index]['isLiked'] = !_posts[index]['isLiked'];
      if (_posts[index]['isLiked']) {
        _posts[index]['likes']++;
      } else {
        _posts[index]['likes']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 정렬 및 카테고리 선택 바
              _buildSortAndCategoryBar(),
              // 게시글 리스트 뷰
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // FAB과의 간섭 방지
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return AskForPostCard(
                      post: post,
                      onLikeTap: () => _toggleLike(index),
                    );
                  },
                ),
              ),
            ],
          ),
          // 글 작성 버튼 (Floating Action Button)
          Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostScreen()),
                );
              },
              backgroundColor: const Color(0xFFAED6F1), // 메인 디자인 테마 색상
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 정렬 및 카테고리 바 위젯
  Widget _buildSortAndCategoryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: ['최신순', '인기순', '마감순'].map((sort) {
              final isSelected = _selectedSort == sort;
              return GestureDetector(
                onTap: () => setState(() => _selectedSort = sort),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    sort,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 게시글 카드 위젯 (ListView에 들어가는 각 박스)
class AskForPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLikeTap;

  const AskForPostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 대표 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: post['image'] != null
                  ? DecorationImage(
                      image: NetworkImage(post['image']),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[200],
            ),
            child: post['image'] == null
                ? const Center(
                    child: Text(
                      'No Image',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // 2. 제목, 태그, 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 & 좋아요 하트 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onLikeTap,
                      child: Icon(
                        post['isLiked']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post['isLiked'] ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 태그
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (post['tags'] as List<String>).map((tag) {
                    return Text(
                      '#$tag',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // 댓글, 조회수, 좋아요
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['comments']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['views']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
