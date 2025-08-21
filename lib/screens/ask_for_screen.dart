import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 공통 토큰은 별칭으로
import 'ask_for_common.dart' as theme;

// 분리한 화면들
import 'post_preview_screen.dart';
import 'application_form_screen.dart';

// PostScreen 클래스만 사용 (상수는 숨김)
import 'post_screen.dart' show PostScreen;

/// 홈스크린의 하늘색 FAB가 호출할 콜백을 보관
class AskForScreenController {
  static Future<void> Function()? create; // PostScreen 열고 결과를 리스트에 insert
}

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
      "headcount": 3, // ✅ 모집 인원 추가
      "content": "운동 메이트 구해요를 위한 더미 데이터 내용을 넣어봅시다",
      "questions": [
        "간단한 자기소개를 부탁드려요.",
        "운동 루틴과 시간대는 어떻게 되나요?",
        "어떤 목표로 함께 하길 원하시나요?",
      ],
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
      // ✅ 여기! null 대신 마감 날짜를 넣어줘 (예: 3일 뒤 마감)
      "deadlineAt": DateTime.now().add(const Duration(days: 3)),
      "urgentOverlay": false,
      "headcount": 3, // ✅ 모집 인원 추가
      "questions": ["수령 방법은 어떻게 원하시나요?", "책 상태는 어느 정도인가요?", "네고 가능 여부를 알려주세요."],
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
      "urgentOverlay": true,
      "headcount": 3, // ✅ 모집 인원 추가
      "questions": [
        "선호하는 음식/알레르기를 알려주세요.",
        "예산 범위를 알려주세요.",
        "가능한 요일/시간대를 알려주세요.",
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    AskForScreenController.create = _openCreateAndAppend;
  }

  @override
  void dispose() {
    if (AskForScreenController.create == _openCreateAndAppend) {
      AskForScreenController.create = null;
    }
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      final liked = _posts[index]["isLiked"] == true;
      _posts[index]["isLiked"] = !liked;
      _posts[index]["likes"] += liked ? -1 : 1;
    });
  }

  Future<void> _openCreateAndAppend() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostScreen()),
    );
    if (!mounted) return;
    if (result is Map<String, dynamic>) {
      setState(() {
        _posts.insert(0, result);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("게시글이 등록되었습니다.")));
    }
  }

  void _openPreviewScreen(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostPreviewScreen(
          post: post,
          // 미리보기 화면의 "지원하기"에서 지원서로 이동 (질문 전달)
          onApply: () {
            final qs =
                (post["questions"] as List?)?.cast<String>() ??
                const <String>[];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ApplicationFormScreen(post: post, questions: qs),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applySort(List<Map<String, dynamic>> list) {
    final sorted = [...list];
    final now = DateTime.now();
    int nullSafe<T>(
      T? a,
      T? b,
      int Function(T, T) cmp, {
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
          (a, b) => nullSafe<DateTime>(
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
          if (d == null) return 3;
          if (d.isBefore(now)) return 2;
          return 1;
        }
        sorted.sort((a, b) {
          final ra = rank(a), rb = rank(b);
          if (ra != rb) return ra.compareTo(rb);
          return nullSafe<DateTime>(
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
      backgroundColor: theme.kPageBg,
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
                  onTap: () => _openPreviewScreen(post), // ← 전체화면 미리보기 이동
                );
              },
            ),
          ),
        ],
      ),
      // FAB는 HomeScreen에서 배치하므로 여기엔 없음
    );
  }

  Widget _buildSortAndCategoryBar() {
    const scale = 1.0; // ✅ 전체 스케일
    final chipRadius = 14.0 * scale;
    final chipHPad = 10.0 * scale;
    final chipVPad = 6.0 * scale;
    final fontSize = 12.0 * scale; // ✅ 칩 텍스트 크기
    final iconSize = 14.0 * scale; // ✅ 칩 오른쪽 아이콘 크기

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10.0 * scale),
      decoration: const BoxDecoration(
        color: theme.kWhite,
        border: Border(bottom: BorderSide(color: theme.kDivider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                      color: theme.kWhite,
                      borderRadius: BorderRadius.circular(chipRadius),
                      border: Border.all(
                        color: selected ? theme.kTextPrimary : const Color.fromARGB(255, 211, 211, 211),
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
                        color: theme.kTextPrimary,
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
          _CategoryChipMenu(
            label: _selectedCategory,
            items: _categories,
            onSelected: (v) => setState(() => _selectedCategory = v),
            accent: const Color.fromARGB(255, 88, 188, 255),
            radius: chipRadius,
            hPad: chipHPad,
            vPad: chipVPad,
            fontSize: fontSize, // ✅ 카테고리 박스 글자 크기
            iconSize: iconSize,
            menuItemHeight: 40.0 * scale, // ✅ 드롭다운 메뉴 항목 높이
            menuFontSize: 15.0 * scale, // ✅ 드롭다운 안 텍스트 크기
            maxMenuWidth: 160.0 * scale, // ✅ 드롭다운 메뉴 전체 박스 너비
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
          color: theme.kWhite,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          constraints: BoxConstraints(minWidth: 0, maxWidth: maxMenuWidth),
          items: items.map((e) {
            final isSel = e == label;
            return PopupMenuItem<String>(
              value: e,
              height: menuItemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 18,
                height: 18,
                child: Opacity(
                  opacity: widget.isSelected ? 1 : 0,
                  child: const Icon(
                    Icons.check,
                    size: 18,
                    color: theme.kTextPrimary,
                  ),
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
      elevation: 0,
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
                color: theme.kWhite,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: theme.kDivider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.1,
                      color: theme.kTextPrimary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: 4 * (fontSize / 12.0)),
                  const FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: 14,
                    color: theme.kTextPrimary,
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
  final VoidCallback? onTap;

  const AskForPostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    this.onTap,
  });

  bool get _hasDeadline => post["deadlineAt"] is DateTime;
  bool get _isExpired =>
      _hasDeadline && (post["deadlineAt"] as DateTime).isBefore(DateTime.now());
  bool get _showUrgentOverlay =>
      (post["urgentOverlay"] is bool) && post["urgentOverlay"] == true;

  Widget _buildThumb() {
    final img = post["image"];
    Widget thumb;
    if (img is Uint8List) {
      thumb = Image.memory(img, fit: BoxFit.cover);
    } else if (img is String && img.trim().isNotEmpty) {
      thumb = Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      thumb = Container(color: Colors.grey[200]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: theme.kThumbSize,
        height: theme.kThumbSize,
        child: Stack(
          children: [
            Positioned.fill(child: thumb),
            if (_showUrgentOverlay)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 24,
                  alignment: Alignment.center,
                  color: theme.kUrgentRed,
                  child: const Text(
                    "마감임박",
                    style: TextStyle(
                      color: theme.kWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String category =
        (post["category"] as String?)?.trim().isNotEmpty == true
        ? post["category"]
        : "기타";
    final double opacity = _isExpired ? 0.55 : 1.0;
    final List<String> tags = (post["tags"] is List)
        ? List<String>.from(post["tags"])
        : const [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IgnorePointer(
        ignoring: _isExpired,
        child: Opacity(
          opacity: opacity,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(theme.kCardPad),
                  decoration: BoxDecoration(
                    color: theme.kWhite,
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
                      _buildThumb(),
                      const SizedBox(width: 12),
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
                                    ((post["title"] as String?)
                                                ?.trim()
                                                .isEmpty ??
                                            true)
                                        ? "제목 없음"
                                        : post["title"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: theme.kTextPrimary,
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
                                    (post["isLiked"] == true)
                                        ? FontAwesomeIcons.solidHeart
                                        : FontAwesomeIcons.heart,
                                    size: 20,
                                    color: (post["isLiked"] == true)
                                        ? theme.kHeartRed
                                        : theme.kHeartGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // 해시태그
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: tags
                                  .map(
                                    (tag) => Text(
                                      "#$tag",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: theme.kTextMuted,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 34),
                            // 메타
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.solidCommentDots,
                                  size: 13,
                                  color: theme.kTextMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${post["comments"] ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: theme.kTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const FaIcon(
                                  FontAwesomeIcons.solidEye,
                                  size: 13,
                                  color: theme.kTextMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${post["views"] ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: theme.kTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const FaIcon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 13,
                                  color: theme.kHeartRed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${post["likes"] ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: theme.kHeartRed,
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
                  child: _CategoryChip(label: category),
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.kDivider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: theme.kTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
