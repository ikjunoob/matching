import 'package:flutter/material.dart';

class AskForScreen extends StatefulWidget {
  const AskForScreen({super.key});

  @override
  State<AskForScreen> createState() => _AskForScreenState();
}

class _AskForScreenState extends State<AskForScreen> {
  String _selectedSort = '최신순';
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '스터디', '재능공유', '물품대여', '운동메이트'];

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
      _posts[index]['likes'] += _posts[index]['isLiked'] ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _selectedCategory == '전체'
        ? _posts
        : _posts.where((p) => p['category'] == _selectedCategory).toList();

    return Column(
      children: [
        _buildSortAndCategoryBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: visiblePosts.length,
            itemBuilder: (context, index) {
              final post = visiblePosts[index];
              final originalIdx = _posts.indexWhere((p) => identical(p, post));
              final idx = originalIdx == -1 ? index : originalIdx;
              return AskForPostCard(
                post: post,
                onLikeTap: () => _toggleLike(idx),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- 상단 정렬 버튼 + 카테고리 메뉴(커스텀 팝업) ----
  Widget _buildSortAndCategoryBar() {
    const accent = Color(0xFF00FFFB);

    const chipHeight = 28.0;
    const chipRadius = 14.0;
    const chipHPad = 10.0;
    const chipVPad = 5.0;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 정렬 칩
          Row(
            children: ['최신순', '인기순', '마감순'].map((sort) {
              final selected = _selectedSort == sort;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(chipRadius),
                  onTap: () => setState(() => _selectedSort = sort),
                  child: Container(
                    height: chipHeight,
                    padding: EdgeInsets.only(
                      left: chipHPad,
                      right: chipHPad,
                      top: chipVPad - 2, // 기존보다 위쪽 여백 줄이기
                      bottom: chipVPad + 2, // 아래쪽 여백 늘려서 글자 올라가게
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(chipRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            selected ? 0.08 : 0.03,
                          ),
                          blurRadius: selected ? 6 : 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: selected
                            ? Colors.black
                            : const Color(0xFFE6E8EB),
                      ),
                    ),
                    child: Text(
                      sort,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // 카테고리 칩 + showMenu 팝업
          _CategoryChipMenu(
            label: _selectedCategory,
            items: _categories,
            onSelected: (v) => setState(() => _selectedCategory = v),
            accent: accent,
            height: chipHeight,
            radius: chipRadius,
            hPad: chipHPad,
            vPad: chipVPad,
          ),
        ],
      ),
    );
  }
}

// ========= 커스텀 카테고리 칩 + showMenu =========
class _CategoryChipMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final Color accent;
  final double height, radius, hPad, vPad;

  const _CategoryChipMenu({
    required this.label,
    required this.items,
    required this.onSelected,
    required this.accent,
    required this.height,
    required this.radius,
    required this.hPad,
    required this.vPad,
  });

  @override
  Widget build(BuildContext context) {
    return _ChipButton(
      label: label,
      height: height,
      radius: radius,
      hPad: hPad,
      vPad: vPad,
      onTap: (box) async {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final position = RelativeRect.fromRect(
          Rect.fromPoints(
            box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
            box.localToGlobal(
              box.size.bottomRight(Offset.zero),
              ancestor: overlay,
            ),
          ),
          Offset.zero & overlay.size,
        );

        final selected = await showMenu<String>(
          context: context,
          position: position,
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // ✨ 폭 제어 (예: 내용에 더 타이트하게)
          constraints: const BoxConstraints(
            minWidth: 0, // 기본 최소폭 해제
            maxWidth: 130, // 원하는 최대폭으로 제한 (수치 조절)
          ),

          items: items.map((e) {
            final isSel = e == label;
            return PopupMenuItem<String>(
              value: e,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: _HoverMenuTile(text: e, isSelected: isSel, accent: accent),
            );
          }).toList(),
        );

        if (selected != null) onSelected(selected);
      },
    );
  }
}

// Hover 전용 타일 (메뉴 항목에 사용)
class _HoverMenuTile extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color accent;

  const _HoverMenuTile({
    required this.text,
    required this.isSelected,
    required this.accent,
  });

  @override
  State<_HoverMenuTile> createState() => _HoverMenuTileState();
}

class _HoverMenuTileState extends State<_HoverMenuTile> {
  bool _hovered = false;
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || _tapped || widget.isSelected;

    return Listener(
      onPointerDown: (_) => setState(() => _tapped = true),
      onPointerUp: (_) => setState(() => _tapped = false),
      onPointerCancel: (_) => setState(() => _tapped = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? widget.accent.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌: 텍스트, 우: 체크
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 18,
                height: 18,
                child: Opacity(
                  opacity: widget.isSelected ? 1 : 0,
                  child: const Icon(Icons.check, size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 칩 모양 버튼(정렬 칩과 동일 규격)
class _ChipButton extends StatelessWidget {
  final String label;
  final double height, radius, hPad, vPad;
  final void Function(RenderBox box) onTap;

  const _ChipButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.hPad,
    required this.vPad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: Builder(
        builder: (ctx) {
          return InkWell(
            borderRadius: BorderRadius.circular(radius),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              final box = ctx.findRenderObject() as RenderBox;
              onTap(box);
            },
            child: Container(
              height: height,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: const Color(0xFFE6E8EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== 리스트 카드 =====
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
    final String category =
        (post['category'] as String?)?.trim().isNotEmpty == true
        ? post['category']
        : '기타';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일
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
                // 본문
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 + 하트
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              post['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                        spacing: 4,
                        runSpacing: 4,
                        children: (post['tags'] as List<String>).map((tag) {
                          return Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // 수치
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['comments']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['views']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 우하단 카테고리 배지 (작게)
          Positioned(
            right: 12,
            bottom: 12,
            child: _CategoryChip(label: category),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6E8EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
