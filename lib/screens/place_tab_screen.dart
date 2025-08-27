import "dart:typed_data";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

// 공통 토큰 (임시 정의)
import "ask_for_common.dart" as theme;
import "place_create_screen.dart"; // ★ 장소 작성 화면

/// 홈에서 오버레이 FAB가 호출할 콜백을 보관 (구해요와 동일 패턴)
class PlaceTabScreenController {
  static Future<void> Function()? create;
}

/// 장소 탭 전용 화면
class PlaceTabScreen extends StatefulWidget {
  const PlaceTabScreen({super.key});
  @override
  State<PlaceTabScreen> createState() => _PlaceTabScreenState();
}

class _PlaceTabScreenState extends State<PlaceTabScreen> {
  // 요구 순서: 인기순 → 최신순 → 좋아요순
  String _selectedSort = "인기순";
  String _selectedCategory = "전체";

  // 장소용 카테고리 6개 (+전체)
  final List<String> _categories = const [
    "전체",
    "카페",
    "스터디룸",
    "운동시설",
    "도서관",
    "공원",
    "라운지",
  ];

  // 더미 데이터
  final List<Map<String, dynamic>> _places = [
    {
      "image": null,
      "title": "24시 독서실",
      "address": "경기도 성남시 분당구 정자동 10-20",
      "category": "스터디룸",
      "comments": 12,
      "views": 165,
      "likes": 77,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    },
    {
      "image": null,
      "title": "캠퍼스 스터디 카페",
      "address": "서울시 강남구 역삼동 123-45",
      "category": "카페",
      "comments": 120,
      "views": 150,
      "likes": 93,
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      "image": null,
      "title": "체육관 헬스장",
      "address": "부산시 해운대구 우동 30-40",
      "category": "운동시설",
      "comments": 18,
      "views": 138,
      "likes": 62,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "image": null,
      "title": "아늑한 북카페",
      "address": "서울시 서초구 서초동 67-89",
      "category": "카페",
      "comments": 56,
      "views": 98,
      "likes": 34,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    },
    {
      "image": null,
      "title": "학교 운동장",
      "address": "대구시 수성구 범어동 50-60",
      "category": "공원",
      "comments": 6,
      "views": 50,
      "likes": 26,
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    // 홈의 FAB가 부를 콜백을 연결
    PlaceTabScreenController.create = _openCreateAndAppend;
  }

  @override
  void dispose() {
    if (PlaceTabScreenController.create == _openCreateAndAppend) {
      PlaceTabScreenController.create = null;
    }
    super.dispose();
  }

  // 장소 작성 화면 열고, 결과를 리스트에 insert
  Future<void> _openCreateAndAppend() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const PlaceCreateScreen()),
    );
    if (!mounted) return;

    if (result != null) {
      // place_create_screen.dart의 반환 맵을 카드 포맷으로 변환
      final List images = (result["images"] is List)
          ? result["images"]
          : const [];
      final firstImage = images.isNotEmpty ? images.first as Uint8List : null;

      setState(() {
        _places.insert(0, {
          "image": firstImage,
          "title": (result["name"] ?? "").toString().trim().isEmpty
              ? "제목 없음"
              : result["name"],
          "address": "", // 지도 연동 전이므로 비워둠
          "category": result["category"] ?? "기타",
          "comments": 0,
          "views": 0,
          "likes": 0,
          "isLiked": false,
          "createdAt": DateTime.now(),
        });
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("장소가 등록되었습니다.")));
    }
  }

  List<Map<String, dynamic>> _applySortAndFilter() {
    final filtered = _selectedCategory == "전체"
        ? _places
        : _places.where((p) => p["category"] == _selectedCategory).toList();

    final sorted = [...filtered];
    switch (_selectedSort) {
      case "인기순": // 조회수 기준
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
      final liked = _places[originalIndex]["isLiked"] == true;
      _places[originalIndex]["isLiked"] = !liked;
      _places[originalIndex]["likes"] += liked ? -1 : 1;
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
                final originIndex = _places.indexWhere(
                  (p) => identical(p, item),
                );
                final idx = originIndex == -1 ? i : originIndex;

                return PlaceListCard(
                  data: item,
                  onLikeTap: () => _toggleLike(idx),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 상단 정렬 칩 + 카테고리 드롭다운
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

// ================================================================
// ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ 기존 _CategoryChipMenu를 아래 위젯들로 교체 ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
// ================================================================

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
    // scale 변수들을 상수로 정의
    const double scale = 1.0;
    const double chipRadius = 14.0 * scale;
    const double chipHPad = 10.0 * scale;
    const double chipVPad = 6.0 * scale;
    const double fontSize = 12.0 * scale;
    const double iconSize = 14.0 * scale;
    const double menuItemHeight = 40.0 * scale;
    const double menuFontSize = 15.0 * scale;
    // 요청에 따라 너비를 160으로 고정
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
          // 너비를 160으로 고정
          constraints: const BoxConstraints(
            minWidth: maxMenuWidth,
            maxWidth: maxMenuWidth,
          ),
          items: items.map((e) {
            final isSel = e == label;
            return PopupMenuItem<String>(
              value: e,
              height: menuItemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _HoverMenuTile(
                text: e,
                isSelected: isSel,
                accent: accentColor,
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

/// 드롭다운 메뉴의 각 항목을 위한 위젯 (호버/탭 상태 관리)
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

/// 드롭다운 메뉴를 여는 칩 모양 버튼 위젯
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
                  FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: iconSize,
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
class PlaceListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onLikeTap;

  const PlaceListCard({super.key, required this.data, required this.onLikeTap});

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

  @override
  Widget build(BuildContext context) {
    final liked = data["isLiked"] == true;
    final String category =
        (data["category"] as String?)?.trim().isNotEmpty == true
        ? data["category"]
        : "기타";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Text(
                    data["address"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: theme.kTextMuted,
                      fontSize: 12.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // === 메타(좌) + 카테고리 칩(우) 한 줄 ===
                  Row(
                    children: [
                      // 메타: 댓글 → 조회 → 하트
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

                      // 카테고리 칩 (우측 정렬)
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
    );
  }
}
