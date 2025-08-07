import 'package:flutter/material.dart';

// 커스텀 하단 네비게이션 바 (HTML/CSS 예시 완벽 반영)
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
    // 메인 포인트 컬러
    final accentColor = const Color.fromARGB(255, 0, 255, 251); // HTML 예시 #D8A7B1
    // 아이콘 크기, 바 높이, 버튼 크기
    const navBarHeight = 56.0;
    const floatingSize = 70.0;

    return SizedBox(
      height: navBarHeight + 14, // SVG 곡선 고려 추가
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // SVG 곡선 백그라운드
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(double.infinity, navBarHeight),
              painter: _NavBarBgPainter(),
            ),
          ),
          // 중앙 플로팅 버튼 (SVG 위, 가장 앞으로)
          Positioned(
            bottom: navBarHeight - (floatingSize / 2) + 5, // 위로 띄우기!
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
                        color: accentColor.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
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
          // 네비게이션 아이콘 5개 (플로팅 버튼 공간 비움)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: navBarHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 홈
                  _NavBarIcon(
                    icon: Icons.home_rounded,
                    isActive: currentIndex == 0,
                    accentColor: accentColor,
                    onTap: () => onTap(0),
                  ),
                  // 모임 (네트워크 아이콘)
                  _NavBarIcon(
                    custom: Image.network(
                      "https://cdn-icons-png.flaticon.com/512/1436/1436701.png",
                      width: 28,
                      height: 28,
                      color: currentIndex == 1 ? accentColor : Colors.grey[400],
                    ),
                    isActive: currentIndex == 1,
                    accentColor: accentColor,
                    onTap: () => onTap(1),
                  ),
                  // 중앙 플로팅 자리
                  const Expanded(child: SizedBox()),
                  // 캘린더
                  _NavBarIcon(
                    icon: Icons.calendar_today_outlined,
                    isActive: currentIndex == 3,
                    accentColor: accentColor,
                    onTap: () => onTap(3),
                  ),
                  // 마이페이지
                  _NavBarIcon(
                    icon: Icons.person_rounded,
                    isActive: currentIndex == 4,
                    accentColor: accentColor,
                    onTap: () => onTap(4),
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

// SVG 곡선 Painter (HTML/CSS 곡선과 유사하게, 얕고 부드럽게)
class _NavBarBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // (HTML 예시와 유사한 얕은 곡선)
    path.moveTo(0, 15);
    path.quadraticBezierTo(0, 0, 15, 0);
    path.lineTo(size.width * 0.37, 0);
    path.cubicTo(
      size.width * 0.43,
      0,
      size.width * 0.46,
      15,
      size.width * 0.5,
      35,
    );
    path.cubicTo(
      size.width * 0.54,
      15,
      size.width * 0.57,
      0,
      size.width * 0.63,
      0,
    );
    path.lineTo(size.width - 15, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 15);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.08), 6, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 네비 아이콘 (공통)
class _NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? custom;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavBarIcon({
    super.key,
    this.icon,
    this.custom,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? accentColor : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(child: custom ?? Icon(icon, size: 28, color: color)),
      ),
    );
  }
}
