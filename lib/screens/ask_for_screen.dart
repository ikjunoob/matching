// ask_for_screen.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "post_screen.dart";

/// ===== Design Tokens =====
const kAccent = Color(0xFF00FFFB);
const kPageBg = Color(0xFFF9FAFB);
const kDivider = Color(0xFFE5E7EB);
const kTextPrimary = Color(0xFF111827);
const kTextMuted = Color(0xFF6B7280);
const kWhite = Colors.white;
const kHeartRed = Color(0xFFFF4D4D);
const kHeartGrey = Color(0xFFD1D5DB);
const kUrgentRed = Color(0xFFFF4D4D);

const kThumbSize = 100.0;
const kCardPad = 10.0;

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
      "deadlineAt": null,
      "urgentOverlay": false,
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
    // 홈의 하늘색 FAB에서 부르면 AskForScreen의 컨텍스트로 PostScreen을 열어 처리
    AskForScreenController.create = _openCreateAndAppend;
  }

  @override
  void dispose() {
    // 다른 화면으로 넘어가 콜백이 낡은 참조를 갖지 않도록 정리
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
        _posts.insert(0, result); // 리스트 맨 위에 추가
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("게시글이 등록되었습니다.")));
    }
  }

  void _openPreviewModal(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.98,
          expand: false,
          builder: (_, controller) {
            return _PostPreviewSheet(
              post: post,
              scrollController: controller,
              onApply: () {
                Navigator.of(ctx).pop();
                final qs =
                    (post["questions"] as List?)?.cast<String>() ??
                    const <String>[];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        _ApplicationFormScreen(post: post, questions: qs),
                  ),
                );
              },
            );
          },
        );
      },
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
          final d = p["deadlineAt"] as DateTime?;
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
                  onTap: () => _openPreviewModal(post),
                );
              },
            ),
          ),
        ],
      ),
      // NOTE: 여기엔 floatingActionButton 두지 않음 (중복 방지)
    );
  }

  Widget _buildSortAndCategoryBar() {
    const scale = 0.8;
    final chipRadius = 14.0 * scale;
    final chipHPad = 10.0 * scale;
    final chipVPad = 6.0 * scale;
    final fontSize = 12.0 * scale;
    final iconSize = 14.0 * scale;

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
        width: kThumbSize,
        height: kThumbSize,
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
                                    (post["isLiked"] == true)
                                        ? FontAwesomeIcons.solidHeart
                                        : FontAwesomeIcons.heart,
                                    size: 20,
                                    color: (post["isLiked"] == true)
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
                              children: tags
                                  .map(
                                    (tag) => Text(
                                      "#$tag",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: kTextMuted,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 38),
                            // 메타
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.commentDots,
                                  size: 13,
                                  color: kTextMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${post["comments"] ?? 0}",
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
                                  "${post["views"] ?? 0}",
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
                                  "${post["likes"] ?? 0}",
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

/// ===== 오른쪽 하단 하늘색 + FAB =====
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
        fillColor: kAccent, // 하늘색 배경
        elevation: 6,
        child: const FaIcon(
          FontAwesomeIcons.plus,
          color: kWhite, // 흰색 아이콘
        ),
      ),
    );
  }
}

/// ========= 바텀시트 미리보기 =========
class _PostPreviewSheet extends StatefulWidget {
  final Map<String, dynamic> post;
  final ScrollController scrollController;
  final VoidCallback onApply;
  const _PostPreviewSheet({
    required this.post,
    required this.scrollController,
    required this.onApply,
  });

  @override
  State<_PostPreviewSheet> createState() => _PostPreviewSheetState();
}

class _PostPreviewSheetState extends State<_PostPreviewSheet> {
  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post["isLiked"] ?? false;
    _likeCount = widget.post["likes"] ?? 0;
    _viewCount = widget.post["views"] ?? 0;
  }

  String _formatRemain(DateTime d) {
    final now = DateTime.now();
    if (!d.isAfter(now)) return "마감됨";
    final diff = d.difference(now);
    if (diff.inDays >= 1) return "D-${diff.inDays}";
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return "마감까지 $h시간 $m분";
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.55),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.post["image"];
    final Uint8List? imageBytes = img is Uint8List ? img : null;
    final String? imageUrl = img is String ? img : null;
    final deadline = widget.post["deadlineAt"] as DateTime?;
    final headcount = widget.post["headcount"]?.toString() ?? "";
    final tags = (widget.post["tags"] as List?) ?? [];
    final content = (widget.post["content"] ?? "") as String? ?? "";
    final title = ((widget.post["title"] as String?) ?? "").trim().isEmpty
        ? "제목 없음"
        : widget.post["title"];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageBytes != null)
                        Image.memory(imageBytes, fit: BoxFit.cover)
                      else if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(imageUrl, fit: BoxFit.cover)
                      else
                        Container(color: const Color(0xFFF2F4F7)),
                      if (deadline != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: _pill(_formatRemain(deadline)),
                        ),
                      if (headcount.isNotEmpty)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _pill("$headcount명 모집"),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : kTextPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isLiked = !_isLiked;
                                _likeCount += _isLiked ? 1 : -1;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    (tags.isNotEmpty ? tags : const <String>[])
                                        .map(
                                          (t) => Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: Text(
                                              "#$t",
                                              style: const TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const FaIcon(
                            FontAwesomeIcons.eye,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$_viewCount",
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const FaIcon(
                            FontAwesomeIcons.solidHeart,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$_likeCount",
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content.isEmpty ? "내용이 없습니다." : content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.45,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "지원하기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ========= 질문 폼 화면 =========
class _ApplicationFormScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<String> questions;
  const _ApplicationFormScreen({required this.post, required this.questions});

  @override
  State<_ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<_ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List.generate(
      widget.questions.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _field({String? hint}) => InputDecoration(
    hintText: hint ?? "답변을 입력하세요...",
    hintStyle: const TextStyle(color: kTextMuted),
    filled: true,
    fillColor: Colors.white,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: kDivider),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kDivider),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kAccent, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("지원서가 제출되었습니다.")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.post["title"] as String?) ?? "제목 없음";
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "지원서 작성",
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: kTextPrimary),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "지원할 공고",
                    style: TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "질문",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(widget.questions.length, (i) {
              final q = widget.questions[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == widget.questions.length - 1 ? 0 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${i + 1}. $q",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _answers[i],
                      maxLines: 5,
                      decoration: _field(hint: "답변을 입력하세요..."),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "답변을 입력해 주세요."
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kDivider, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "제출하기",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
