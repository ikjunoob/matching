import 'package:flutter/material.dart';
// 추가
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'dart:ui';
import 'ask_for_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'place_tab_screen.dart'; // ★ 추가

/// ===== Design Tokens (캡처 기준 색상) =====
const kPageBg = Color(0xFFF9FAFB); // 전체 배경
const kCardDivider = Color(0xFFE5E7EB); // 탭바 하단 보더
const kTextPrimary = Color(0xFF111827); // 기본 텍스트
const kTextMuted = Color(0xFF6B7280); // 보조 텍스트/아이콘
const kHeartRed = Color(0xFFFF4D4D); // 하트
const kIndicator = Color(0xFFAED6F1); // 상단 인디케이터(기존 톤 유지)

class HomeScreen extends StatefulWidget {
  final int tabIndex;
  final void Function(int tabIndex)? onTabChange;

  const HomeScreen({super.key, this.tabIndex = 0, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTabIndex;
  final List<String> tabs = ['추천', '모임', '구해요', '장소'];

  // 탭 인디케이터용

  late List<GlobalKey> _tabKeys;
  final GlobalKey _tabBarWrapperKey = GlobalKey(); // 부모 컨테이너 키
  double _indicatorX = 0.0;
  double _indicatorWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabIndex;
    _tabKeys = List.generate(tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition(_selectedTabIndex);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onTabTap(widget.tabIndex);
      });
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _updateIndicatorPosition(index);
    widget.onTabChange?.call(index);
  }

  void _updateIndicatorPosition(int index) {
    final key = _tabKeys[index];
    final RenderBox? child =
        key.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? parent =
        _tabBarWrapperKey.currentContext?.findRenderObject() as RenderBox?;

    if (child != null && parent != null) {
      final childLeftGlobal = child.localToGlobal(Offset.zero).dx;
      final parentLeftGlobal = parent.localToGlobal(Offset.zero).dx;
      final size = child.size;

      setState(() {
        _indicatorX = childLeftGlobal - parentLeftGlobal; // 부모 기준 좌표
        _indicatorWidth = size.width;
      });
    }
  }

  // ✨ 개선점: 핫한 유저 팝업을 띄우는 함수 추가
  void _showUserPopup({
    required String imageUrl,
    required String name,
    required int likes,
    required String tag,
    required String bio,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => UserDetailPopup(
        imageUrl: imageUrl,
        name: name,
        likes: likes,
        tag: tag,
        bio: bio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Image.asset(
                'assets/icons/main_logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.commentDots,
                color: kTextMuted,
                size: 19,
              ),
              tooltip: '채팅',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              },
            ),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.bell,
                color: kTextMuted,
                size: 19,
              ),
              tooltip: '알림',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Container(
            key: _tabBarWrapperKey,
            height: 42,
            color: Colors.white,
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(height: 1, thickness: 1, color: kCardDivider),
                ),
                AnimatedPositioned(
                  left: _indicatorX + (_indicatorWidth * 0.15),
                  width: _indicatorWidth * 0.7,
                  bottom: 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: kIndicator,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return InkWell(
                      key: _tabKeys[index],
                      onTap: () => _onTabTap(index),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? kTextPrimary : kTextMuted,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_selectedTabIndex == 0) {
            // ✅ 추천 탭: maxWidth 768px 적용
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: _buildRecommendTab(),
              ),
            );
          } else if (_selectedTabIndex == 1) {
            return const Center(child: Text("모임 탭 더미"));
          } else if (_selectedTabIndex == 2) {
            // ★ 구해요 글 생성 플로팅 + 버튼
            return Stack(
              children: [
                const AskForScreen(),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: FloatingActionButton(
                      heroTag: "askFab",
                      onPressed: () async {
                        final fn = AskForScreenController.create;
                        if (fn != null) await fn();
                      },
                      elevation: 4,
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Color(0xFF59BDF7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // ★ 장소 글 생성 플로팅 버튼 : PlaceTabScreen + 동일 스타일의 FAB
            return Stack(
              children: [
                const PlaceTabScreen(),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: FloatingActionButton(
                      heroTag: "placeFab",
                      onPressed: () async {
                        final fn = PlaceTabScreenController.create;
                        if (fn != null)
                          await fn(); // place_create_screen 열기 + 인서트
                      },
                      elevation: 4,
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Color(0xFF59BDF7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // -------------------- [추천] 탭 화면 구성 --------------------
  Widget _buildRecommendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: "✨ 이런 모임은 어때요?", onMoreTap: () => _onTabTap(1)),
          const SizedBox(height: 13),
          SizedBox(
            height: 192,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  width: 240,
                  image:
                      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=900&q=80',
                  title: "함께 성장하는 독서 모임",
                  tags: "#독서 #자기계발",
                  heartCount: 120,
                  showPeople: true,
                  showTags: true,
                ),
                _buildCard(
                  width: 240,
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=900&q=80',
                  title: "주말엔 브런치",
                  tags: "#맛집 #취향공유",
                  heartCount: 88,
                  showPeople: true,
                  showTags: true,
                ),
                _buildCard(
                  width: 240,
                  image:
                      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=900&q=80',
                  title: "토요일엔 스터디/기타 긴 이름 예시",
                  tags: "#스터디 #개발 #네트워킹",
                  heartCount: 77,
                  showPeople: true,
                  showTags: true,
                ),
                _buildCard(
                  width: 240,
                  image:
                      'https://images.unsplash.com/photo-1549488344-cbb6c34cf08b?auto=format&fit=crop&w=900&q=80',
                  title: "문화 탐방 모임",
                  tags: "#전시 #문화생활",
                  heartCount: 65,
                  showPeople: true,
                  showTags: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SectionTitle(title: "🎯 취향저격! 추천 장소", onMoreTap: () => _onTabTap(3)),
          const SizedBox(height: 13),
          SizedBox(
            height: 128,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  width: 200,
                  image:
                      'https://images.unsplash.com/photo-1508264165352-258db2ebd59b?auto=format&fit=crop&w=1200&q=80',
                  title: "별 보러 가는 언덕",
                  tags: "",
                  heartCount: 95,
                  showPeople: false,
                  showTags: false,
                ),
                _buildCard(
                  width: 200,
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=1200&q=80',
                  title: "조용한 카페",
                  tags: "",
                  heartCount: 76,
                  showPeople: false,
                  showTags: false,
                ),
                _buildCard(
                  width: 200,
                  image:
                      'https://images.unsplash.com/photo-1559348331-267151a6275a?auto=format&fit=crop&w=1200&q=80',
                  title: "아늑한 북카페",
                  tags: "",
                  heartCount: 54,
                  showPeople: false,
                  showTags: false,
                ),
                _buildCard(
                  width: 200,
                  image:
                      'https://images.unsplash.com/photo-1543394339-a0a39d8cad13?auto=format&fit=crop&w=1200&q=80',
                  title: "캠퍼스 뒤 공원",
                  tags: "",
                  heartCount: 61,
                  showPeople: false,
                  showTags: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SectionTitle(title: "🔥 지금 가장 핫한 유저", onMoreTap: () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 간격 자동 조절
              children: [
                // ✨ 개선점: Expanded로 감싸서 공간을 유연하게 차지하도록 변경
                Expanded(
                  child: _buildUser(
                    imageUrl:
                        "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=300&q=80",
                    name: "제니",
                    likes: 250,
                    tag: "#독서 #자기계발",
                    bio: "함께 성장하며 책을 좋아하는 제니입니다. 새로운 만남을 기대해요!",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUser(
                    imageUrl:
                        "https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=facearea&w=300&q=80",
                    name: "라이언",
                    likes: 210,
                    tag: "#운동 #음악",
                    bio: "음악과 운동을 좋아하는 활기찬 라이언입니다.",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUser(
                    imageUrl:
                        "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=facearea&w=300&q=80",
                    name: "클로이",
                    likes: 180,
                    tag: "#여행 #사진",
                    bio: "여행과 사진으로 추억을 남기는 클로이입니다.",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 카드형 콘텐츠 위젯 --------------------
  Widget _buildCard({
    required String image,
    required String title,
    required String tags,
    required int heartCount,
    double width = 160,
    bool showPeople = true,
    String peopleText = "5/10명",
    bool showTags = true,
    double? titleFontSize, // ✅ nullable: 전달 없으면 타입별 기본값
  }) {
    const kMeetingTitleSize = 19.0;
    const kPlaceTitleSize = 16.0;

    final tagList = tags.trim().isEmpty
        ? <String>[]
        : tags.trim().split(RegExp(r'\s+'));

    final double resolvedTitleSize =
        titleFontSize ?? (showPeople ? kMeetingTitleSize : kPlaceTitleSize);

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 하단 → 상단 그라데이션
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.60), Colors.transparent],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // 👥 모임 카드 → 좌상단 (인원수 + 좋아요)
          if (showPeople)
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: [
                  // 인원수 박스
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.users,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          peopleText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 좋아요 박스
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, size: 13, color: kHeartRed),
                        const SizedBox(width: 3),
                        Text(
                          "$heartCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 📍 장소 카드 → 우상단 (좋아요만)
          if (!showPeople)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, size: 13, color: kHeartRed),
                    const SizedBox(width: 3),
                    Text(
                      "$heartCount",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

          // 제목/태그 (카드 하단)
          Positioned(
            left: 12,
            bottom: 10,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: resolvedTitleSize,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showTags && tagList.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tagList.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            tag.startsWith('#') ? tag : '#$tag',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ➡️ 모임 카드 전용 화살표 버튼 (오른쪽 하단)
          if (showPeople)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------- [핫한 유저] 프로필 위젯 --------------------
  Widget _buildUser({
    required String imageUrl,
    required String name,
    required int likes,
    String tag = "#기본태그",
    String bio = "자기소개 텍스트",
  }) {
    // ✨ 개선점: GestureDetector로 감싸서 탭 가능하도록 만듦
    return GestureDetector(
      onTap: () => _showUserPopup(
        imageUrl: imageUrl,
        name: name,
        likes: likes,
        tag: tag,
        bio: bio,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 76,
                  height: 76,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: kHeartRed, size: 13),
              const SizedBox(width: 3),
              Text(
                "$likes",
                style: const TextStyle(fontSize: 11, color: kTextPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------- 섹션 타이틀 & "더보기" --------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionTitle({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: const Text(
              "더보기 >",
              style: TextStyle(
                color: kTextMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600, // ← 굵기 추가
              ),
            ),
          ),
      ],
    );
  }
}

// -------------------- [핫한 유저] 상세 팝업 위젯 --------------------
class UserDetailPopup extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int likes;
  final String tag;
  final String bio;

  const UserDetailPopup({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.likes,
    required this.tag,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: size.width * 0.9,
          height: size.height * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[800]),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundImage: NetworkImage(imageUrl),
                        onBackgroundImageError: (e, s) =>
                            const Icon(Icons.person, size: 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: tag
                          .split(' ')
                          .where((t) => t.isNotEmpty)
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.54),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                t.startsWith('#') ? t : '#$t',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const Spacer(flex: 1),
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.48),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(
                        bio,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          height: 1.47,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: kHeartRed,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              // ✨ 개선점: 하드코딩된 'Likes' 대신 실제 값을 표시
                              Text(
                                "$likes",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: 프로필 보기 화면으로 이동
                                },
                                child: const Text(
                                  "프로필 보기",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: 채팅 화면으로 이동
                                },
                                child: const Text(
                                  "채팅하기",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(flex: 1),
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
