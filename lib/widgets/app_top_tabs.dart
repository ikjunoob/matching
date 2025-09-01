import 'package:flutter/material.dart';

class HomeTopTabs extends StatefulWidget implements PreferredSizeWidget {
  const HomeTopTabs({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onChanged,
    this.height = 42,
    this.indicatorColor = const Color(0xFFAED6F1),
    this.dividerColor = const Color(0xFFE5E7EB),
    this.activeColor = const Color(0xFF111827),
    this.inactiveColor = const Color(0xFF6B7280),
    this.horizontalPadding = 16,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  final double height;
  final Color indicatorColor;
  final Color dividerColor;
  final Color activeColor;
  final Color inactiveColor;
  final double horizontalPadding;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> {
  late List<GlobalKey> _tabKeys;
  final GlobalKey _wrapperKey = GlobalKey();
  double _indicatorX = 0.0;
  double _indicatorW = 0.0;

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicator(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant HomeTopTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 탭수/인덱스 변경 시 인디케이터 재계산
    if (oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.tabs.length != widget.tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicator(widget.currentIndex);
      });
    }
  }

  void _updateIndicator(int index) {
    final child =
        _tabKeys[index].currentContext?.findRenderObject() as RenderBox?;
    final parent = _wrapperKey.currentContext?.findRenderObject() as RenderBox?;
    if (child == null || parent == null) return;

    final childLeft = child.localToGlobal(Offset.zero).dx;
    final parentLeft = parent.localToGlobal(Offset.zero).dx;
    setState(() {
      _indicatorX = childLeft - parentLeft + (child.size.width * 0.15);
      _indicatorW = child.size.width * 0.7;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _wrapperKey,
      height: widget.height,
      color: Colors.white,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          ),
          AnimatedPositioned(
            left: _indicatorX,
            width: _indicatorW,
            bottom: 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: widget.indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: List.generate(widget.tabs.length, (i) {
              final isSelected = i == widget.currentIndex;
              return InkWell(
                key: _tabKeys[i],
                onTap: () {
                  widget.onChanged(i);
                  // onChanged 후 프레임에서 위치 재계산
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateIndicator(i);
                  });
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.horizontalPadding,
                    vertical: 10,
                  ),
                  child: Text(
                    widget.tabs[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? widget.activeColor
                          : widget.inactiveColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
