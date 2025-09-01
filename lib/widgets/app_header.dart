import 'package:flutter/material.dart';

/// 화면 공통 상단바(AppBar).
/// - 좌측: 로고
/// - 우측: 메시지/알림 아이콘
/// - bottom 주입 가능(탭바 등)
class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  const CommonHeader({
    super.key,
    this.onMessageTap,
    this.onBellTap,
    this.bottom,
    this.logoPath = 'assets/images/cc_logo.png',
  });

  final VoidCallback? onMessageTap;
  final VoidCallback? onBellTap;
  final PreferredSizeWidget? bottom;
  final String logoPath;

  static const _barHeight = 56.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(_barHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false, // ← 뒤로가기 자동삽입 방지
      toolbarHeight: _barHeight,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            logoPath,
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.circle, size: 20, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onMessageTap,
          tooltip: '메시지',
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFF6B7280),
            size: 24,
          ),
        ),
        IconButton(
          onPressed: onBellTap,
          tooltip: '알림',
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF6B7280),
            size: 28,
          ),
        ),
        const SizedBox(width: 6),
      ],
      bottom: bottom, // ← 탭바 등 주입
    );
  }
}
