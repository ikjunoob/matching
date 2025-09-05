import 'dart:typed_data';
import 'package:flutter/gestures.dart'; // ScrollBehavior를 위해 추가
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'work_space.dart'; // 리스트 클릭 -> 워크스페이스 화면 이동
import 'ask_for_common.dart' as theme; // 공통 토큰(색상/패딩/썸네일 사이즈 등)
import 'group_create_screen.dart'; // 모임 생성 화면

/// 홈의 FAB가 호출할 콜백을 보관
class GroupTabScreenController {
  static Future<void> Function()? create;
}

/// 상단 탭
enum GroupTab { recommend, popular, regular, newest }

class GroupTabScreen extends StatefulWidget {
  const GroupTabScreen({super.key});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen> {
  // ===== 상태 =====
  GroupTab _tab = GroupTab.recommend; // 추천/인기/정규/신규
  String _selectedCategory = "전체"; // 카테고리
  int _selectedWeekday = 0; // 정규 요일: 0=전체, 1=월..7=일

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

  // ===== 더미 데이터 =====
  // - weekday: 1=월..7=일 (정규모임 요일)
  // - isRegular: 정규모임 여부
  // - createdAt: 게시 생성일(신규 정렬용)
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
      "isRegular": true,
      "weekday": 3, // 수
      "memberCount": 5,
      "memberLimit": 12,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80",
      "title": "한강에서 치맥 #20",
      "tags": ["친목", "야외"],
      "category": "친목",
      "comments": 21,
      "views": 309,
      "likes": 152,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
      "isRegular": true,
      "weekday": 6, // 토
      "memberCount": 8,
      "memberLimit": 10,
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
      "isRegular": true,
      "weekday": 2, // 화
      "memberCount": 4,
      "memberLimit": 8,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1549880338-65ddcdfd017b?auto=format&fit=crop&w=1200&q=80",
      "title": "주말 등산 모임 #38",
      "tags": ["운동", "친목"],
      "category": "운동",
      "comments": 58,
      "views": 300,
      "likes": 129,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
      "isRegular": true,
      "weekday": 7, // 일
      "memberCount": 10,
      "memberLimit": 15,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=1200&q=80",
      "title": "보드게임 할 사람 #27",
      "tags": ["게임", "친목"],
      "category": "게임",
      "comments": 43,
      "views": 210,
      "likes": 95,
      "isLiked": true,
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
      "isRegular": true,
      "weekday": 5, // 금
      "memberCount": 6,
      "memberLimit": 6,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1529070538774-1843cb3265df?auto=format&fit=crop&w=1200&q=80",
      "title": "영화 감상회 #15",
      "tags": ["문화", "영화"],
      "category": "문화",
      "comments": 18,
      "views": 198,
      "likes": 86,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(hours: 7)),
      "isRegular": false, // 단발/수시
      "weekday": 4, // 참고용
      "memberCount": 3,
      "memberLimit": 20,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?auto=format&fit=crop&w=1200&q=80",
      "title": "맛집 탐방 #9",
      "tags": ["맛집탐방", "한식"],
      "category": "맛집탐방",
      "comments": 11,
      "views": 165,
      "likes": 77,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(hours: 1)),
      "isRegular": true,
      "weekday": 4, // 목
      "memberCount": 5,
      "memberLimit": 10,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1512654448050-44b3700c42fa?auto=format&fit=crop&w=1200&q=80",
      "title": "카페 스터디 #18",
      "tags": ["스터디", "카페"],
      "category": "스터디",
      "comments": 15,
      "views": 172,
      "likes": 81,
      "isLiked": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 4)),
      "isRegular": true,
      "weekday": 1, // 월
      "memberCount": 2,
      "memberLimit": 6,
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

  // FAB -> 생성 화면 -> 결과를 리스트에 삽입
  Future<void> _openCreateAndAppend() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const GroupCreateScreen()),
    );
    if (!mounted || result == null) return;

    setState(() {
      _groups.insert(0, {
        "image": result["image"],
        "title": result["title"],
        "tags": result["tags"] ?? const <String>[], // ← 생성 화면의 태그 반영
        "category": result["category"] ?? "기타",
        "comments": 0,
        "views": 0,
        "likes": 0,
        "isLiked": false,
        "createdAt": DateTime.now(),
        "isRegular": result["isRegular"] ?? true,
        "weekday": result["weekday"] ?? 6, // 토
        "memberCount": result["memberCount"] ?? 1,
        "memberLimit": result["memberLimit"] ?? 10,
        "raw": result,
      });
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("모임이 등록되었습니다.")));
  }

  // ===== 탭/카테고리/요일 적용 후 정렬 =====
  List<Map<String, dynamic>> _applyTabSortFilter() {
    // 1) 카테고리 필터
    Iterable<Map<String, dynamic>> list = _selectedCategory == "전체"
        ? _groups
        : _groups.where((g) => g["category"] == _selectedCategory);

    // 2) 탭/요일 필터 + 정렬
    switch (_tab) {
      case GroupTab.recommend:
        // 간단 추천 점수: likes*2 + views
        final sorted = [...list];
        sorted.sort((a, b) {
          int sa = (a["likes"] as int) * 2 + (a["views"] as int);
          int sb = (b["likes"] as int) * 2 + (b["views"] as int);
          return sb.compareTo(sa);
        });
        return sorted;

      case GroupTab.popular:
        final sorted = [...list];
        sorted.sort((a, b) => (b["views"] as int).compareTo(a["views"] as int));
        return sorted;

      case GroupTab.regular:
        list = list.where((g) => g["isRegular"] == true);
        if (_selectedWeekday != 0) {
          list = list.where((g) => g["weekday"] == _selectedWeekday);
        }
        // 정렬: 요일(월→일), 동일 요일이면 좋아요/조회수 가벼운 가중치
        final sorted = [...list];
        sorted.sort((a, b) {
          final wa = (a["weekday"] as int);
          final wb = (b["weekday"] as int);
          if (wa != wb) return wa.compareTo(wb);
          final sa = (a["likes"] as int) * 2 + (a["views"] as int);
          final sb = (b["likes"] as int) * 2 + (b["views"] as int);
          return sb.compareTo(sa);
        });
        return sorted;

      case GroupTab.newest:
        final sorted = [...list];
        sorted.sort(
          (a, b) => (b["createdAt"] as DateTime).compareTo(
            a["createdAt"] as DateTime,
          ),
        );
        return sorted;
    }
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
    final visible = _applyTabSortFilter();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // 상단 탭/필터 바
          _TopFilterBar(
            tab: _tab,
            onChangeTab: (t) => setState(() => _tab = t),
            selectedCategory: _selectedCategory,
            onChangeCategory: (v) => setState(() => _selectedCategory = v),
            categories: _categories,
          ),

          // 정규 탭일 때만 요일 필터 노출
          if (_tab == GroupTab.regular)
            _WeekdayFilterBar(
              selected: _selectedWeekday,
              onSelected: (d) => setState(() => _selectedWeekday = d),
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

/// ================= 상단: 탭(추천/인기/정규/신규) + 카테고리칩 =================
class _TopFilterBar extends StatelessWidget {
  final GroupTab tab;
  final ValueChanged<GroupTab> onChangeTab;
  final String selectedCategory;
  final ValueChanged<String> onChangeCategory;
  final List<String> categories;

  const _TopFilterBar({
    required this.tab,
    required this.onChangeTab,
    required this.selectedCategory,
    required this.onChangeCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ AskForScreen과 동일한 스케일/사이즈
    const double scale = 1.0;
    final double chipRadius = 14.0 * scale;
    final double chipHPad = 10.0 * scale;
    final double chipVPad = 6.0 * scale;
    final double fontSize = 12.0 * scale;
    final double iconSize = 14.0 * scale;

    final tabs = <(String, GroupTab)>[
      ("추천", GroupTab.recommend),
      ("인기", GroupTab.popular),
      ("정규", GroupTab.regular),
      ("신규", GroupTab.newest),
    ];

    Widget buildChip(String label, bool sel, VoidCallback onTap) {
      return Padding(
        padding: EdgeInsets.only(right: 6.0 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(chipRadius),
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: chipHPad,
              vertical: chipVPad,
            ),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF1F2937) : theme.kWhite,
              borderRadius: BorderRadius.circular(chipRadius),
              border: Border.all(
                color: sel ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                width: 1,
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
              label,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.1,
                color: sel ? theme.kWhite : theme.kTextPrimary,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44), // ✅ AskFor 기준
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10.0 * scale,
      ), // ✅ AskFor 기준
      decoration: const BoxDecoration(
        color: theme.kWhite,
        border: Border(bottom: BorderSide(color: theme.kDivider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌: 탭 칩들
          Row(
            children: tabs
                .map(
                  (e) => buildChip(e.$1, tab == e.$2, () => onChangeTab(e.$2)),
                )
                .toList(),
          ),
          // 우: 카테고리 드롭다운 칩 (AskFor와 동일 파라미터 전달)
          _CategoryChipMenu(
            label: selectedCategory,
            items: categories,
            onSelected: onChangeCategory,
            accent: const Color.fromARGB(255, 88, 188, 255),
            radius: chipRadius,
            hPad: chipHPad,
            vPad: chipVPad,
            fontSize: fontSize, // ✅ 텍스트 크기
            iconSize: iconSize, // ✅ 아이콘 크기
            menuItemHeight: 40.0 * scale, // ✅ 메뉴 아이템 높이
            menuFontSize: 15.0 * scale, // ✅ 메뉴 폰트
            maxMenuWidth: 160.0 * scale, // ✅ 메뉴 너비
          ),
        ],
      ),
    );
  }
}

/// ================= 정규 탭 전용: 슬라이딩 애니메이션 요일 필터 =================

// 스크롤바를 숨기기 위한 사용자 정의 ScrollBehavior
class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // 스크롤바를 그리지 않고 자식 위젯만 반환
  }
}

class _WeekdayFilterBar extends StatefulWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _WeekdayFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_WeekdayFilterBar> createState() => _WeekdayFilterBarState();
}

class _WeekdayFilterBarState extends State<_WeekdayFilterBar> {
  // 높이/패딩 조절 상수 (전체 높이 살짝 감소)
  static const double _trackHPad = 8.0; // 트랙 좌우 여백 ↑ (오버플로 방지)
  static const double _trackVPad = 3.0; // 트랙 상하 여백 ↓
  static const double _itemHPad = 14.0; // 아이템 좌우 여백(기존 16)
  static const double _itemVPad = 10.0; // 아이템 상하 여백(기존 8)
  static const double _fontSize = 14.0; // 폰트(기존 13)

  final List<(String, int)> options = const [
    ("전체", 0),
    ("월", 1),
    ("화", 2),
    ("수", 3),
    ("목", 4),
    ("금", 5),
    ("토", 6),
    ("일", 7),
  ];

  final List<GlobalKey> _keys = [];
  final List<double> _widths = [];
  double _indicatorWidth = 0;
  double _indicatorLeft = 0;

  // ✅ [추가] 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(options.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureItems();
      _updateIndicator(widget.selected, animate: false);
    });
  }

  // ✅ [추가] 스크롤 컨트롤러 메모리 해제
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _WeekdayFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (_widths.isNotEmpty) {
        _updateIndicator(widget.selected);
      }
    }
  }

  void _measureItems() {
    if (!mounted) return;
    _widths.clear();
    for (var key in _keys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _widths.add(renderBox.size.width);
      } else {
        _widths.add(0);
      }
    }
  }

  void _updateIndicator(int value, {bool animate = true}) {
    final selectedIndex = options.indexWhere((opt) => opt.$2 == value);
    if (selectedIndex == -1 || selectedIndex >= _widths.length) return;

    // 선택된 아이템의 중앙 위치 계산
    double itemCenter = 0;
    for (int i = 0; i < selectedIndex; i++) {
      itemCenter += _widths[i];
    }
    itemCenter += _widths[selectedIndex] / 2;

    // 스크롤 뷰의 현재 보이는 영역의 중앙 위치 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollViewportCenter = screenWidth / 2;

    // ✅ [추가] 선택된 아이템이 화면 중앙에 오도록 스크롤 위치를 조정합니다.
    _scrollController.animateTo(
      // (아이템 중앙 위치 - 화면 중앙) 만큼 스크롤
      (itemCenter - scrollViewportCenter).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 350), // 애니메이션 지속 시간
      curve: Curves.easeOut, // 애니메이션 커브
    );

    double left = 0;
    for (int i = 0; i < selectedIndex; i++) {
      left += _widths[i];
    }

    if (mounted) {
      setState(() {
        _indicatorWidth = _widths[selectedIndex];
        _indicatorLeft = left;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: theme.kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ScrollConfiguration(
        behavior: NoScrollbarBehavior(),
        child: SingleChildScrollView(
          // ✅ [수정] 스크롤 컨트롤러 연결
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _trackHPad,
              vertical: _trackVPad,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // theme.kcontents 와 동일
              borderRadius: BorderRadius.circular(10),
            ),
            child: IntrinsicWidth(
              child: Stack(
                children: [
                  // 선택 인디케이터
                  AnimatedPositioned(
                    // ✅ [수정] 애니메이션 시간을 350ms로 늘려 더 부드럽게
                    duration: const Duration(milliseconds: 350),
                    // ✅ [수정] 애니메이션 커브를 변경하여 더 동적인 느낌을 줍니다.
                    curve: Curves.easeInOutCubic,
                    left: _indicatorLeft,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _indicatorWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 요일 텍스트들
                  Row(
                    children: options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = widget.selected == option.$2;

                      return GestureDetector(
                        key: _keys[index],
                        onTap: () => widget.onSelected(option.$2),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _itemHPad,
                            vertical: _itemVPad,
                          ),
                          child: Text(
                            option.$1,
                            style: TextStyle(
                              fontSize: _fontSize,
                              height: 1.1,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChipMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  // ✅ AskForScreen과 동일 파라미터
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
          constraints: BoxConstraints(
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
                    accent: accent,
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
                      fontWeight: FontWeight.w500,
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

    final int memberCount = (data["memberCount"] ?? 0) as int;
    final int memberLimit = (data["memberLimit"] ?? 0) as int;

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
                    // 태그 라인 (제목 아래 한 줄)
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
                              // ✅ 인원수 표기 형식: "x/y" (공백 제거)
                              const FaIcon(
                                FontAwesomeIcons.users,
                                size: 13,
                                color: theme.kTextMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$memberCount/$memberLimit",
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
