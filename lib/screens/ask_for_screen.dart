import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'post_screen.dart';

/// ===== Design Tokens =====
const kAccent = Color(0xFF00FFFB); // 상단 인디케이터/포인트
const kPageBg = Color(0xFFF9FAFB); // 페이지 배경
const kDivider = Color(0xFFE5E7EB); // 탭바/바텀 보더
const kTextPrimary = Color(0xFF111827);
const kTextMuted = Color(0xFF6B7280);
const kWhite = Colors.white;
const kHeartRed = Color(0xFFFF4D4D); // 하트(좋아요)
const kHeartGrey = Color(0xFFD1D5DB); // 비활성 하트 외곽
const kUrgentRed = Color(0xFFFF4D4D); // "마감임박" 배너

// 이미지/카드 여백 관련
const kThumbSize = 100.0; // 썸네일 크기 (88 → 100으로 확대)
const kCardPad = 10.0; // 카드 패딩 (12 → 10으로 살짝 줄임)

class AskForScreen extends StatefulWidget {
  const AskForScreen({super.key});

  @override
  State<AskForScreen> createState() => _AskForScreenState();
}

class _AskForScreenState extends State<AskForScreen> {
  String _selectedSort = "최신순";
  String _selectedCategory = "전체";

  final List<String> _categories = ["전체", "스터디", "재능공유", "물품대여", "운동메이트"];

  // 더미 데이터
  final List<Map<String, dynamic>> _posts = [
    {
      "image":
          "https://images.unsplash.com/photo-1571902943202-507ec2618e8f?q=80&w=1000&auto=format&fit=crop",
      "title": "운동 메이트 구해요 (헬스)",
      "tags": ["운동", "헬스", "메이트"],
      "comments": 3,
      "views": 52,
      "likes": 71,
      "category": "운동메이트",
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(hours: 4)),
      "deadlineAt": DateTime.now().add(const Duration(days: 2)),
      "urgentOverlay": false,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=2070&auto=format&fit=crop",
      "title": "중고 전공서적 판매합니다",
      "tags": ["중고거래", "전공서적"],
      "comments": 7,
      "views": 136,
      "likes": 79,
      "category": "물품대여",
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      "deadlineAt": null,
      "urgentOverlay": false,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1887&auto=format&fit=crop",
      "title": "같이 점심 먹을 사람 구해요!",
      "tags": ["점심", "맛집", "같이먹어요"],
      "comments": 17,
      "views": 237,
      "likes": 160,
      "category": "맛집",
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(hours: 10)),
      "deadlineAt": DateTime.now().add(const Duration(hours: 6)),
      "urgentOverlay": true, // <- 3번째만 "마감임박"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1592899677977-9c1035e235e7?q=80&w=1887&auto=format&fit=crop",
      "title": "아이패드 충전기 빌려주실 분?",
      "tags": ["물품공유", "아이패드", "충전기"],
      "comments": 5,
      "views": 150,
      "likes": 123,
      "category": "물품대여",
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
      "deadlineAt": DateTime.now().subtract(const Duration(days: 1)), // 마감 지남
      "urgentOverlay": false,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1521737711867-e3b97375f902?q=80&w=1887&auto=format&fit=crop",
      "title": "공모전 팀원 모집합니다 (기획/디자인)",
      "tags": ["팀원모집", "공모전", "기획", "디자인"],
      "comments": 8,
      "views": 266,
      "likes": 26,
      "category": "스터디",
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(hours: 2)),
      "deadlineAt": DateTime.now().add(const Duration(days: 7)),
      "urgentOverlay": false,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      _posts[index]["isLiked"] = !_posts[index]["isLiked"];
      _posts[index]["likes"] += _posts[index]["isLiked"] ? 1 : -1;
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
      ).showSnackBar(const SnackBar(content: Text("게시글이 등록되었습니다.")));
    }
  }

  // 정렬
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
      case "최신순":
        sorted.sort(
          (a, b) => nullSafeCompare<DateTime>(
            b["createdAt"],
            a["createdAt"],
            (x, y) => x.compareTo(y),
          ),
        );
        break;
      case "인기순":
        sorted.sort((a, b) => (b["likes"] as int).compareTo(a["likes"] as int));
        break;
      case "마감순":
        int rank(Map<String, dynamic> p) {
          final DateTime? d = p["deadlineAt"];
          if (d == null) return 3; // 마감 없음
          if (d.isBefore(now)) return 2; // 이미 마감
          return 1; // 진행중
        }
        sorted.sort((a, b) {
          final ra = rank(a), rb = rank(b);
          if (ra != rb) return ra.compareTo(rb);
          return nullSafeCompare<DateTime>(
            a["deadlineAt"],
            b["deadlineAt"],
            (x, y) => x.compareTo(y),
          );
        });
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == "전체"
        ? _posts
        : _posts.where((p) => p["category"] == _selectedCategory).toList();

    final visiblePosts = _applySort(filtered);

    return Scaffold(
      backgroundColor: kPageBg,
      body: Column(
        children: [
          _buildSortAndCategoryBar(),
          Expanded(
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
        ],
      ),
      // floatingActionButton: _CreateFab(onTap: _openCreateAndAppend),
    );
  }

  /// ===== 상단 정렬/카테고리 바 =====
  Widget _buildSortAndCategoryBar() {
    const double scale = 0.8;

    final double chipRadius = 14.0 * scale;
    final double chipHPad = 10.0 * scale;
    final double chipVPad = 6.0 * scale;
    final double fontSize = 12.0 * scale;
    final double iconSize = 14.0 * scale;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10.0 * scale),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(bottom: BorderSide(color: kDivider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 정렬 칩
          Row(
            children: ["최신순", "인기순", "마감순"].map((sort) {
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
                      color: kWhite,
                      borderRadius: BorderRadius.circular(chipRadius),
                      border: Border.all(
                        color: selected ? kTextPrimary : kDivider,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            selected ? 0.08 : 0.03,
                          ),
                          blurRadius: selected ? 6 : 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      sort,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 1.1,
                        color: kTextPrimary,
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
          // 카테고리 드롭다운
          _CategoryChipMenu(
            label: _selectedCategory,
            items: _categories,
            onSelected: (v) => setState(() => _selectedCategory = v),
            accent: kAccent,
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
    );
  }
}

/// ========= 카테고리 메뉴 & 관련 위젯 =========
class _CategoryChipMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final Color accent;

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
          color: kWhite,
          elevation: 10,
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
                    color: kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 18,
                height: 18,
                child: Opacity(
                  opacity: widget.isSelected ? 1 : 0,
                  child: const Icon(Icons.check, size: 18, color: kTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                color: kWhite,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: kDivider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.1,
                      color: kTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4 * (fontSize / 12.0)),
                  FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: iconSize,
                    color: kTextPrimary,
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

/// ===== 리스트 카드 =====
class AskForPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLikeTap;

  const AskForPostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
  });

  bool get _hasDeadline => post["deadlineAt"] is DateTime;
  bool get _isExpired =>
      _hasDeadline && (post["deadlineAt"] as DateTime).isBefore(DateTime.now());
  bool get _showUrgentOverlay =>
      (post["urgentOverlay"] is bool) && post["urgentOverlay"] == true;

  @override
  Widget build(BuildContext context) {
    final String category =
        (post["category"] as String?)?.trim().isNotEmpty == true
        ? post["category"]
        : "기타";

    final double opacity = _isExpired ? 0.55 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IgnorePointer(
        ignoring: _isExpired,
        child: Opacity(
          opacity: opacity,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(kCardPad),
                decoration: BoxDecoration(
                  color: kWhite,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: kThumbSize,
                        height: kThumbSize,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                post["image"] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey[200]),
                              ),
                            ),
                            if (_showUrgentOverlay)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                child: Container(
                                  height: 24,
                                  alignment: Alignment.center,
                                  color: kUrgentRed,
                                  child: const Text(
                                    "마감임박",
                                    style: TextStyle(
                                      color: kWhite,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                                  post["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: kTextPrimary,
                                    decoration: _isExpired
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: onLikeTap,
                                child: FaIcon(
                                  post["isLiked"]
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 20,
                                  color: post["isLiked"]
                                      ? kHeartRed
                                      : kHeartGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // 해시태그
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: (post["tags"] as List<String>).map((tag) {
                              return Text(
                                "#$tag",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: kTextMuted,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 38),
                          
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.commentDots,
                                size: 13,
                                color: kTextMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${post["comments"]}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kTextMuted,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const FaIcon(
                                FontAwesomeIcons.eye,
                                size: 13,
                                color: kTextMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${post["views"]}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kTextMuted,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const FaIcon(
                                FontAwesomeIcons.solidHeart,
                                size: 13,
                                color: kHeartRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${post["likes"]}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kHeartRed,
                                ),
                              ),
                            ],
                          ),
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
                child: _CategoryChip(
                  label:
                      (post["category"] as String?)?.trim().isNotEmpty == true
                      ? post["category"]
                      : "기타",
                ),
              ),
            ],
          ),
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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kDivider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          color: kTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 필요 시 사용하는 플로팅 + 버튼 (요구 규격: 56x56, 원형)
class _CreateFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: RawMaterialButton(
        onPressed: onTap,
        shape: const CircleBorder(),
        fillColor: kWhite,
        elevation: 6,
        child: const FaIcon(FontAwesomeIcons.plus, color: kTextPrimary),
      ),
    );
  }
}
