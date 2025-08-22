import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFAED6F1);
    const navBarHeight = 56.0;
    const floatingSize = 64.0;

    final double floatingBottom = navBarHeight / 2 - 4; // (↑ 클수록 위로)

    return SizedBox(
      height: navBarHeight + 24,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 바 배경
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(double.infinity, navBarHeight),
              painter: _NavBarBgPainter(),
            ),
          ),
          // 중앙 플로팅 버튼
          Positioned(
            bottom: floatingBottom,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  width: floatingSize,
                  height: floatingSize,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.podcasts, color: Colors.black, size: 30),
                  ),
                ),
              ),
            ),
          ),
          // 네비게이션 아이콘
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: navBarHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 홈 (FontAwesome home)
                  _NavBarIcon(
                    icon: FontAwesomeIcons.home,
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                    size: 26,
                  ),
                  // 모임/커뮤니티 (Material diversity_3)
                  _NavBarIcon(
                    icon: Icons.diversity_3,
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                    size: 28,
                  ),
                  const Expanded(child: SizedBox()),
                  // 시간표/캘린더 (FontAwesome calendar-alt)
                  _NavBarIcon(
                    icon: FontAwesomeIcons.calendarAlt,
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                    size: 24,
                  ),
                  // 마이페이지 (FontAwesome user-circle)
                  _NavBarIcon(
                    icon: FontAwesomeIcons.userCircle,
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== 배경 Painter (변경 없음) =====
class _NavBarBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final topBorderPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);

    final double curveWidth = 0.20;
    final double dipStart = size.width * (0.504 - curveWidth / 2);
    final double dipEnd = size.width * (0.5 + curveWidth / 2);
    final double dipCenter = size.width * 0.50;
    final double dipDepth = 30;

    path.lineTo(dipStart, 0);
    path.cubicTo(
      dipStart + size.width * 0.02,
      0,
      dipCenter - size.width * 0.02,
      dipDepth,
      dipCenter,
      dipDepth,
    );
    path.cubicTo(
      dipCenter + size.width * 0.02,
      dipDepth,
      dipEnd - size.width * 0.02,
      0,
      dipEnd,
      0,
    );

    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.09), 8, false);
    canvas.drawPath(path, paint);

    final topBorderPath = Path();
    topBorderPath.moveTo(0, 20);
    topBorderPath.quadraticBezierTo(0, 0, 20, 0);
    topBorderPath.lineTo(dipStart, 0);
    topBorderPath.cubicTo(
      dipStart + size.width * 0.02,
      0,
      dipCenter - size.width * 0.02,
      dipDepth,
      dipCenter,
      dipDepth,
    );
    topBorderPath.cubicTo(
      dipCenter + size.width * 0.02,
      dipDepth,
      dipEnd - size.width * 0.02,
      0,
      dipEnd,
      0,
    );
    topBorderPath.lineTo(size.width - 20, 0);
    topBorderPath.quadraticBezierTo(size.width, 0, size.width, 20);

    canvas.drawPath(topBorderPath, topBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== 아이콘 Wrapper =====
class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final double size;

  const _NavBarIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
