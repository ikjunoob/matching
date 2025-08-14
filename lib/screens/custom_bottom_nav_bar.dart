import 'package:flutter/material.dart';

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
    const navBarHeight = 52.0;
    const floatingSize = 60.0;

    // 중앙 버튼을 더 위로 올림 (양수방향)
    final double floatingBottom = navBarHeight / 2 - 4; // (여기서 숫자 크게 할수록 위로!)

    return SizedBox(
      height: navBarHeight + 24, // 충분한 여유
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
          // 중앙 플로팅 버튼 (더 위로)
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
                    child: Icon(Icons.podcasts, color: Colors.black, size: 28),
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
                  _NavBarIcon(
                    icon: Icons.home_rounded,
                    isActive: currentIndex == 0,
                    accentColor: accentColor,
                    onTap: () => onTap(0),
                    size: 28, // 홈 아이콘 크게
                  ),
                  _NavBarIcon(
                    custom: Image.network(
                      "https://cdn-icons-png.flaticon.com/512/1436/1436701.png",
                      width: 25,
                      height: 25,
                      color: currentIndex == 1 ? accentColor : Colors.grey[400],
                    ),
                    isActive: currentIndex == 1,
                    accentColor: accentColor,
                    onTap: () => onTap(1),
                    // size는 custom 사용 시 무시됨
                  ),
                  const Expanded(child: SizedBox()),
                  _NavBarIcon(
                    icon: Icons.calendar_today_outlined,
                    isActive: currentIndex == 3,
                    accentColor: accentColor,
                    onTap: () => onTap(3),
                    size: 28, // 캘린더 아이콘 크게
                  ),
                  _NavBarIcon(
                    icon: Icons.person_rounded,
                    isActive: currentIndex == 4,
                    accentColor: accentColor,
                    onTap: () => onTap(4),
                    size: 28, // 내 정보 아이콘 크게
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

// 움푹 파인 곡선: 더 좁고 부드럽게!
class _NavBarBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 배경 Paint
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 위쪽 Border Paint (1px, 연한 회색)
    final topBorderPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 좌측 라운드
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);

    // 파인 부분 시작/끝
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

    // 그림자 + 배경
    canvas.drawShadow(path, Colors.black.withOpacity(0.09), 8, false);
    canvas.drawPath(path, paint);

    // 위쪽 Border만
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

// 네비 아이콘
class _NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? custom;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;
  final double size; // 아이콘 크기

  const _NavBarIcon({
    this.icon,
    this.custom,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
    this.size = 22, // 기본값(기존 크기)
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: custom ?? Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
