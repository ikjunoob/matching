// group_tab_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'work_space.dart'; // 리스트 클릭 -> 워크스페이스 화면 이동
import 'ask_for_common.dart' as theme; // 공통 토큰(색상/패딩/썸네일 사이즈 등)

/// 홈의 FAB가 호출할 콜백을 보관
class GroupTabScreenController {
  static Future<void> Function()? create;
}

/// 모임 탭
class GroupTabScreen extends StatefulWidget {
  const GroupTabScreen({super.key});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen> {
  // 정렬(인기→최신→좋아요) + 카테고리(예시)
  String _selectedSort = "인기순";
  String _selectedCategory = "전체";

  // 카테고리 목록
  final List<String> _categories = const [
    "전체",
    "운동",
    "스터디",
    "맛집탐방",
    "게임",
    "친목",
    "문화",
  ];

  // ===== 더미 데이터 (이미지 URL은 Unsplash) =====
  final List<Map<String, dynamic>> _groups = [
    {
      "image":
          "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80",
      "title": "코딩 챌린지 #5",
      "tags": ["스터디", "개발"],
      "category": "스터디",
      "comments": 62,
      "views": 327,
      "likes": 164,
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "image":
          "https://images.unsplash.com/photo-1514517220031-65f23f5a1f1c?auto=format&fit=crop&w=1200&q=80",
      "title": "한강에서 치맥 #20",
      "tags": ["친목", "야외"],
      "category": "친목",
      "comments": 21,
      "views": 309,
      "likes": 152,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "image":
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&q=80",
      "title": "발표 스터디 #2",
      "tags": ["스터디", "발표연습"],
      "category": "스터디",
      "comments": 32,
      "views": 214,
      "likes": 162,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      "image":
          "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80",
      "title": "주말 등산 모임 #38",
      "tags": ["운동", "친목"],
      "category": "운동",
      "comments": 58,
      "views": 300,
      "likes": 129,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "image":
          "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1200&q=80",
      "title": "보드게임 할 사람 #27",
      "tags": ["게임", "친목"],
      "category": "게임",
      "comments": 43,
      "views": 210,
      "likes": 95,
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    // 홈 FAB 와이어링
    GroupTabScreenController.create = _openCreateAndAppend;
  }

  @override
  void dispose() {
    if (GroupTabScreenController.create == _openCreateAndAppend) {
      GroupTabScreenController.create = null;
    }
    super.dispose();
  }

  // 리스트 클릭 -> 워크스페이스 화면 이동
  void _openWorkspace(Map<String, dynamic> item) {
    final String t = (item['title'] ?? '').toString().trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkSpaceScreen(title: t.isEmpty ? '워크스페이스 (더미)' : t),
      ),
    );
  }

  // (임시) 모임 생성 화면 연결 자리: 지금은 스텁 바텀시트로 더미 추가
  Future<void> _openCreateAndAppend() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const _CreateGroupStub(),
    );

    if (!mounted || result == null) return;

    setState(() {
      _groups.insert(0, {
        "image": result["image"],
        "title": result["title"],
        "tags": result["tags"],
        "category": result["category"],
        "comments": 0,
        "views": 0,
        "likes": 0,
        "isLiked": false,
        "createdAt": DateTime.now(),
        "raw": result,
      });
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("모임이 등록되었습니다.")));
  }

  List<Map<String, dynamic>> _applySortAndFilter() {
    final filtered = _selectedCategory == "전체"
        ? _groups
        : _groups.where((g) => g["category"] == _selectedCategory).toList();

    final sorted = [...filtered];
    switch (_selectedSort) {
      case "인기순":
        sorted.sort((a, b) => (b["views"] as int).compareTo(a["views"] as int));
        break;
      case "최신순":
        sorted.sort(
          (a, b) => (b["createdAt"] as DateTime).compareTo(
            a["createdAt"] as DateTime,
          ),
        );
        break;
      case "좋아요순":
        sorted.sort((a, b) => (b["likes"] as int).compareTo(a["likes"] as int));
        break;
    }
    return sorted;
  }

  void _toggleLike(int originalIndex) {
    setState(() {
      final liked = _groups[originalIndex]["isLiked"] == true;
      _groups[originalIndex]["isLiked"] = !liked;
      _groups[originalIndex]["likes"] += liked ? -1 : 1;
      if (_groups[originalIndex]["likes"] < 0) {
        _groups[originalIndex]["likes"] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _applySortAndFilter();

    return Scaffold(
      backgroundColor: theme.kPageBg,
      body: Column(
        children: [
          _SortAndCategoryBar(
            selectedSort: _selectedSort,
            onChangeSort: (v) => setState(() => _selectedSort = v),
            selectedCategory: _selectedCategory,
            onChangeCategory: (v) => setState(() => _selectedCategory = v),
            categories: _categories,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 140),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final item = visible[i];
                final originIndex = _groups.indexWhere(
                  (g) => identical(g, item),
                );
                final idx = originIndex == -1 ? i : originIndex;

                return GroupListCard(
                  data: item,
                  onLikeTap: () => _toggleLike(idx),
                  onTap: () => _openWorkspace(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= 공통 상단 바(정렬 칩 + 카테고리 칩) =================
class _SortAndCategoryBar extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onChangeSort;
  final String selectedCategory;
  final ValueChanged<String> onChangeCategory;
  final List<String> categories;

  const _SortAndCategoryBar({
    required this.selectedSort,
    required this.onChangeSort,
    required this.selectedCategory,
    required this.onChangeCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    const sorts = ["인기순", "최신순", "좋아요순"];
    const scale = 1.0;
    final chipR = 14.0 * scale, hPad = 10.0 * scale, vPad = 6.0 * scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10 * scale),
      decoration: const BoxDecoration(
        color: theme.kWhite,
        border: Border(bottom: BorderSide(color: theme.kDivider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: sorts.map((s) {
              final sel = s == selectedSort;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(chipR),
                  onTap: () => onChangeSort(s),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: vPad,
                    ),
                    decoration: BoxDecoration(
                      color: theme.kWhite,
                      borderRadius: BorderRadius.circular(chipR),
                      border: Border.all(
                        color: sel
                            ? theme.kTextPrimary
                            : const Color(0xFFD3D3D3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(sel ? 0.08 : 0.03),
                          blurRadius: sel ? 6 : 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        height: 1.1,
                        color: theme.kTextPrimary,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          _CategoryChipMenu(
            label: selectedCategory,
            items: categories,
            onSelected: onChangeCategory,
          ),
        ],
      ),
    );
  }
}

class _CategoryChipMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _CategoryChipMenu({
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const double scale = 1.0;
    const double chipRadius = 14.0 * scale;
    const double chipHPad = 10.0 * scale;
    const double chipVPad = 6.0 * scale;
    const double fontSize = 12.0 * scale;
    const double iconSize = 14.0 * scale;
    const double menuItemHeight = 40.0 * scale;
    const double menuFontSize = 15.0 * scale;
    const double maxMenuWidth = 160.0;
    const Color accentColor = Color.fromARGB(255, 88, 188, 255);

    return _ChipButton(
      label: label,
      radius: chipRadius,
      hPad: chipHPad,
      vPad: chipVPad,
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
          constraints: const BoxConstraints(
            minWidth: maxMenuWidth,
            maxWidth: maxMenuWidth,
          ),
          items: items
              .map(
                (e) => PopupMenuItem<String>(
                  value: e,
                  height: menuItemHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _HoverMenuTile(
                    text: e,
                    isSelected: e == label,
                    accent: accentColor,
                    fontSize: menuFontSize,
                  ),
                ),
              )
              .toList(),
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

/// ================= 리스트 카드(PlaceTab과 동일 레이아웃/사이즈) =================
class GroupListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onLikeTap;
  final VoidCallback? onTap;

  const GroupListCard({
    super.key,
    required this.data,
    required this.onLikeTap,
    this.onTap,
  });

  Widget _thumb() {
    final img = data["image"];
    Widget child;
    if (img is Uint8List) {
      child = Image.memory(img, fit: BoxFit.cover);
    } else if (img is String && img.trim().isNotEmpty) {
      child = Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      child = Container(
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text(
          "No Image",
          style: TextStyle(
            color: theme.kTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: theme.kThumbSize,
        height: theme.kThumbSize,
        child: child,
      ),
    );
  }

  String _tagsLine() {
    final raw = data["tags"];
    if (raw is List) {
      final list = raw.whereType<String>().toList();
      if (list.isEmpty) return "";
      return list
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .map((t) => t.startsWith('#') ? t : '#$t')
          .join(' ');
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final liked = data["isLiked"] == true;
    final String category =
        (data["category"] as String?)?.trim().isNotEmpty == true
        ? data["category"]
        : "기타";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
              _thumb(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 하트(우상단)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data["title"] ?? "제목 없음",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: theme.kTextPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onLikeTap,
                          child: FaIcon(
                            liked
                                ? FontAwesomeIcons.solidHeart
                                : FontAwesomeIcons.heart,
                            size: 20,
                            color: liked ? theme.kHeartRed : theme.kHeartGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 태그 라인(Place의 주소 라인 자리)
                    Text(
                      _tagsLine(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: theme.kTextMuted,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 메타(좌) + 카테고리 칩(우)
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.solidCommentDots,
                                size: 13,
                                color: theme.kTextMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${data["comments"] ?? 0}",
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
                                "${data["views"] ?? 0}",
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
                                "${data["likes"] ?? 0}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: theme.kHeartRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: theme.kDivider),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: theme.kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

/// ===== 임시 생성 스텁(연결 전까지 사용) =====
class _CreateGroupStub extends StatelessWidget {
  const _CreateGroupStub();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Text(
              "모임 만들기 (스텁)",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: theme.kTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "실제 생성 화면 연결 전까지 임시로 더미 모임을 추가합니다.",
              style: TextStyle(color: theme.kTextMuted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA7FF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop<Map<String, dynamic>>(context, {
                    "image":
                        "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=1200&q=80",
                    "title": "새로운 모임 제목",
                    "tags": ["친목", "자기계발"],
                    "category": "친목",
                  });
                },
                child: const Text(
                  "더미 모임 추가",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "취소",
                style: TextStyle(color: theme.kTextPrimary),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
