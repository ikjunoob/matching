import 'package:flutter/material.dart';
import 'post_screen.dart';

class AskForScreen extends StatefulWidget {
  const AskForScreen({super.key});

  @override
  State<AskForScreen> createState() => _AskForScreenState();
}

// “마감 임박” 기준은 24시간 이내로 설정했어. 필요하면 Duration(hours: 24) 값을 바꿔서 조절하면 돼.
// 마감 글은 제목에 취소선, 카드 전체 opacity 0.55, 좋아요 탭 시 스낵바 노출로 상호작용 차단.
// 진행중이면서 마감일이 있는 글은 “D-n” 또는 “마감까지 n시간 m분”을 보여줘.
// 정렬은 현재 로직 그대로 “마감 임박/진행중 → 마감 지남 → 마감 없음” 순서로 정렬되고, 같은 그룹에서는 마감이 가까운 순서가 위로 와.
class _AskForScreenState extends State<AskForScreen> {
  String _selectedSort = '최신순';
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '스터디', '재능공유', '물품대여', '운동메이트'];

  // 더미 데이터: createdAt, deadlineAt 포함
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
      'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
      'deadlineAt': DateTime.now().add(const Duration(days: 2)),
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
      'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'deadlineAt': null, // 마감 없음
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
      'createdAt': DateTime.now().subtract(const Duration(hours: 10)),
      'deadlineAt': DateTime.now().add(const Duration(hours: 6)), // 임박 케이스
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
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      'deadlineAt': DateTime.now().subtract(const Duration(days: 1)), // 마감 지남
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
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'deadlineAt': DateTime.now().add(const Duration(days: 7)),
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      _posts[index]['isLiked'] = !_posts[index]['isLiked'];
      _posts[index]['likes'] += _posts[index]['isLiked'] ? 1 : -1;
    });
  }

  Future<void> _openCreateAndAppend() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostScreen()),
    );
    if (result is Map<String, dynamic>) {
      setState(() {
        _posts.insert(0, result);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다.')));
    }
  }

  // 정렬 적용
  List<Map<String, dynamic>> _applySort(List<Map<String, dynamic>> list) {
    final sorted = [...list];
    final now = DateTime.now();

    int nullSafeCompare<T>(
      T? a,
      T? b,
      int Function(T x, T y) cmp, {
      bool nullsLast = true,
    }) {
      if (a == null && b == null) return 0;
      if (a == null) return nullsLast ? 1 : -1;
      if (b == null) return nullsLast ? -1 : 1;
      return cmp(a, b);
    }

    switch (_selectedSort) {
      case '최신순':
        sorted.sort(
          (a, b) => nullSafeCompare<DateTime>(
            b['createdAt'],
            a['createdAt'],
            (x, y) => x.compareTo(y),
          ),
        );
        break;
      case '인기순':
        sorted.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
        break;
      case '마감순':
        int rank(Map<String, dynamic> p) {
          final DateTime? d = p['deadlineAt'];
          if (d == null) return 3; // 마감 없음: 최하
          if (d.isBefore(now)) return 2; // 이미 마감: 아래
          return 1; // 진행중: 최우선
        }

        sorted.sort((a, b) {
          final ra = rank(a), rb = rank(b);
          if (ra != rb) return ra.compareTo(rb);
          // 같은 그룹끼리는 가까운 마감이 먼저
          return nullSafeCompare<DateTime>(
            a['deadlineAt'],
            b['deadlineAt'],
            (x, y) => x.compareTo(y),
          );
        });
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == '전체'
        ? _posts
        : _posts.where((p) => p['category'] == _selectedCategory).toList();

    final visiblePosts = _applySort(filtered);

    return Scaffold(
      body: Column(
        children: [
          _buildSortAndCategoryBar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF6F7F9),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 140),
                itemCount: visiblePosts.length,
                itemBuilder: (context, index) {
                  final post = visiblePosts[index];
                  final originalIdx = _posts.indexWhere(
                    (p) => identical(p, post),
                  );
                  final idx = originalIdx == -1 ? index : originalIdx;
                  return AskForPostCard(
                    post: post,
                    onLikeTap: () => _toggleLike(idx),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 상단 정렬/카테고리 바 (비율 스케일 적용) =====
  Widget _buildSortAndCategoryBar() {
    const double scale = 0.8;
    const accent = Color(0xFF00FFFB);

    final double chipRadius = 14.0 * scale;
    final double chipHPad = 10.0 * scale;
    final double chipVPad = 6.0 * scale;
    final double fontSize = 12.0 * scale;
    final double iconSize = 16.0 * scale;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4.0 * scale),
      margin: const EdgeInsets.only(bottom: 8),
      child: Transform.translate(
        offset: const Offset(0, -4), // 위로 4px 올림
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 정렬 칩들
            Row(
              children: ['최신순', '인기순', '마감순'].map((sort) {
                final selected = _selectedSort == sort;
                return Padding(
                  padding: EdgeInsets.only(right: 6.0 * scale),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(chipRadius),
                    onTap: () => setState(() => _selectedSort = sort),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: chipHPad,
                        vertical: chipVPad,
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
                          fontSize: fontSize,
                          height: 1.1,
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

            // 카테고리 칩 + 팝업
            _CategoryChipMenu(
              label: _selectedCategory,
              items: _categories,
              onSelected: (v) => setState(() => _selectedCategory = v),
              accent: accent,
              radius: chipRadius,
              hPad: chipHPad,
              vPad: chipVPad,
              fontSize: fontSize,
              iconSize: iconSize,
              menuItemHeight: 40.0 * scale,
              menuFontSize: 14.0 * scale,
              maxMenuWidth: 130.0 * scale,
            ),
          ],
        ),
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

  // 비율 적용 파라미터
  final double radius, hPad, vPad, fontSize, iconSize;
  final double menuItemHeight, menuFontSize, maxMenuWidth;

  const _CategoryChipMenu({
    required this.label,
    required this.items,
    required this.onSelected,
    required this.accent,
    required this.radius,
    required this.hPad,
    required this.vPad,
    required this.fontSize,
    required this.iconSize,
    required this.menuItemHeight,
    required this.menuFontSize,
    required this.maxMenuWidth,
  });

  @override
  Widget build(BuildContext context) {
    return _ChipButton(
      label: label,
      radius: radius,
      hPad: hPad,
      vPad: vPad,
      fontSize: fontSize,
      iconSize: iconSize,
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
          constraints: BoxConstraints(minWidth: 0, maxWidth: maxMenuWidth),
          items: items.map((e) {
            final isSel = e == label;
            return PopupMenuItem<String>(
              value: e,
              height: menuItemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: _HoverMenuTile(
                text: e,
                isSelected: isSel,
                accent: accent,
                fontSize: menuFontSize,
              ),
            );
          }).toList(),
        );

        if (selected != null) onSelected(selected);
      },
    );
  }
}

class _HoverMenuTile extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color accent;
  final double fontSize;

  const _HoverMenuTile({
    required this.text,
    required this.isSelected,
    required this.accent,
    required this.fontSize,
  });

  @override
  State<_HoverMenuTile> createState() => _HoverMenuTileState();
}

class _HoverMenuTileState extends State<_HoverMenuTile> {
  bool _hovered = false;
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _tapped || widget.isSelected;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    height: 1.1,
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

// 칩 버튼(고정 height 제거, 스케일 적용)
class _ChipButton extends StatelessWidget {
  final String label;
  final double radius, hPad, vPad, fontSize, iconSize;
  final void Function(RenderBox box) onTap;

  const _ChipButton({
    required this.label,
    required this.radius,
    required this.hPad,
    required this.vPad,
    required this.fontSize,
    required this.iconSize,
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
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.1,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4 * (fontSize / 12.0)),
                  Icon(
                    Icons.arrow_drop_down,
                    size: iconSize,
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

  bool get _hasDeadline => post['deadlineAt'] is DateTime;
  bool get _isExpired {
    if (!_hasDeadline) return false;
    return (post['deadlineAt'] as DateTime).isBefore(DateTime.now());
  }

  bool get _isUrgent {
    if (!_hasDeadline) return false;
    final d = post['deadlineAt'] as DateTime;
    final now = DateTime.now();
    return d.isAfter(now) && d.difference(now) <= const Duration(hours: 24);
  }

  String? _remainText() {
    if (!_hasDeadline) return null;
    final d = post['deadlineAt'] as DateTime;
    final now = DateTime.now();
    if (d.isBefore(now)) return '마감됨';
    final diff = d.difference(now);
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return '마감까지 $h시간 $m분';
    }
    final days = diff.inDays;
    return 'D-$days';
  }

  @override
  Widget build(BuildContext context) {
    final String category =
        (post['category'] as String?)?.trim().isNotEmpty == true
        ? post['category']
        : '기타';

    // 2) 마감 글 흐리게
    final double opacity = _isExpired ? 0.55 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Opacity(
        opacity: opacity,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: _isExpired
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // 3) 마감 글 인터랙션 비활성
                                if (_isExpired) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('이미 마감된 글입니다.'),
                                      duration: Duration(milliseconds: 1200),
                                    ),
                                  );
                                  return;
                                }
                                onLikeTap();
                              },
                              child: Icon(
                                post['isLiked']
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post['isLiked']
                                    ? Colors.red
                                    : Colors.grey,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // 배지들: "마감 임박" / "마감" / 남은 시간
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (_isUrgent)
                              const _Badge(
                                label: '마감 임박',
                                bg: Color(0xFFFFEAEA),
                                fg: Color(0xFFD32F2F),
                              ),
                            if (_isExpired)
                              const _Badge(
                                label: '마감',
                                bg: Color(0xFFEDEFF2),
                                fg: Color(0xFF6B7280),
                              ),
                            if (!_isExpired && _hasDeadline)
                              _Badge(
                                label: _remainText()!,
                                bg: const Color(0xFFE6FFFB),
                                fg: const Color(0xFF006D6D),
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
            // 우하단 카테고리 배지
            Positioned(
              right: 12,
              bottom: 12,
              child: _CategoryChip(label: category),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1.2,
        ),
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
