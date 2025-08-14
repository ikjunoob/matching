import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'dart:ui';
import 'ask_for_screen.dart';
import 'post_screen.dart';

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

  // GlobalKey 리스트와 인디케이터의 위치/너비를 저장할 변수 추가
  late List<GlobalKey> _tabKeys;
  double _indicatorX = 0.0;
  double _indicatorWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabIndex;

    // 각 탭에 대한 GlobalKey 생성
    _tabKeys = List.generate(tabs.length, (_) => GlobalKey());

    // UI가 모두 그려진 직후에 초기 인디케이터 위치를 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition(_selectedTabIndex);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      // 현재 빌드가 끝난 후 다음 프레임에서 _onTabTap을 호출하도록 예약
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onTabTap(widget.tabIndex);
      });
    }
  }

  // 탭을 눌렀을 때 인디케이터 위치를 업데이트하는 로직
  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _updateIndicatorPosition(index);
    widget.onTabChange?.call(index);
  }

  // 선택된 탭의 실제 위치와 너비를 계산하는 함수
  void _updateIndicatorPosition(int index) {
    final key = _tabKeys[index];
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final size = renderBox.size;
      // 부모인 Row로부터의 상대적인 위치를 계산
      final position = renderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );

      setState(() {
        _indicatorX = position.dx; // 탭의 상대적 X 위치
        _indicatorWidth = size.width; // 탭의 실제 너비
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.asset(
                    'assets/icons/main_logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Image.asset(
                    'assets/icons/chat_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  tooltip: '채팅',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 26),
                  tooltip: '알림',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ===== 상단 탭바 (GlobalKey 및 애니메이션 로직 최종 적용) =====
          Container(
            color: Colors.white,
            height: 42,
            child: Stack(
              children: [
                // 하단 구분선
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE6E8EB),
                  ),
                ),
                // 애니메이션 인디케이터
                AnimatedPositioned(
                  // left: (전체 너비 - 줄어든 너비)의 절반만큼 더해서 중앙 정렬
                  left: _indicatorX + (_indicatorWidth * 0.15),
                  // width: 측정된 너비의 70%만 사용 (이 값을 조절해 길이 변경)
                  width: _indicatorWidth * 0.7,
                  bottom: 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFAED6F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 탭 버튼들
                Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return InkWell(
                      key: _tabKeys[index], // 각 탭에 고유 Key 할당
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
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ===== 탭별 컨텐츠 =====
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedTabIndex == 0) {
                  return _buildRecommendTab();
                } else if (_selectedTabIndex == 1) {
                  return const Center(child: Text("모임 탭 더미"));
                } else if (_selectedTabIndex == 2) {
                  return Stack(
                    children: [
                      const AskForScreen(),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: SafeArea(
                          child: FloatingActionButton(
                            heroTag: "askFab",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PostScreen(),
                                ),
                              );
                            },
                            backgroundColor: const Color(0xFFAED6F1),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text("장소 탭 더미"));
                }
              },
            ),
          ),
        ],
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
          // ===== 모임 추천 =====
          SectionTitle(title: "✨ 이런 모임은 어때요?", onMoreTap: () => _onTabTap(1)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80',
                  title: "함께 성장하는 독서 모임",
                  tags: "#독서 #자기계발",
                  heartCount: 120,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "주말엔 브런치",
                  tags: "#맛집 #취향공유",
                  heartCount: 88,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "토요일엔 스터디/기타 긴 이름 예시",
                  tags: "#스터디 #개발 #네트워킹",
                  heartCount: 77,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "문화 탐방 모임",
                  tags: "#전시 #문화생활",
                  heartCount: 65,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ===== 장소 추천 (인원수 뱃지 제거) =====
          SectionTitle(title: "🎯 취향저격! 추천 장소", onMoreTap: () => _onTabTap(3)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1508264165352-258db2ebd59b?auto=format&fit=crop&w=800',
                  title: "별 보러 가는 언덕",
                  tags: "#자연 #밤하늘",
                  heartCount: 95,
                  showPeople: false, // 인원수 숨김
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=800',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  showPeople: false,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=800',
                  title: "아늑한 북카페",
                  tags: "#독서 #휴식",
                  heartCount: 54,
                  showPeople: false,
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=800',
                  title: "캠퍼스 뒤 공원",
                  tags: "#산책 #자연",
                  heartCount: 61,
                  showPeople: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ===== 핫한 유저 (더보기 버튼만 표시, 기능 없음) =====
          SectionTitle(title: "🔥 지금 가장 핫한 유저", onMoreTap: () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 26.0, right: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUser(
                  "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&q=80",
                  "제니",
                  250,
                  tag: "#독서 #자기계발",
                  bio: "함께 성장하며 책을 좋아하는 제니입니다. 새로운 만남을 기대해요!",
                ),
                _buildUser(
                  "https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=facearea&w=200&q=80",
                  "라이언",
                  210,
                  tag: "#운동 #음악",
                  bio: "음악과 운동을 좋아하는 활기찬 라이언입니다.",
                ),
                _buildUser(
                  "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=facearea&w=200&q=80",
                  "클로이",
                  180,
                  tag: "#여행 #사진",
                  bio: "여행과 사진으로 추억을 남기는 클로이입니다.",
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
    bool showPeople = true, // 인원수 표시 여부
    String peopleText = "5/10명", // 인원 텍스트
    VoidCallback? onArrowTap,
  }) {
    final tagList = tags.trim().split(RegExp(r'\s+'));

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                if (showPeople)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.group, size: 13, color: Colors.white),
                        const SizedBox(width: 2),
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
                if (showPeople) const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 13,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 2),
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
          Positioned(
            left: 10,
            bottom: 10,
            right: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                tagList.length <= 2
                    ? Wrap(
                        spacing: 6,
                        children: tagList.where((tag) => tag.isNotEmpty).map((
                          tag,
                        ) {
                          return Container(
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
                      )
                    : SizedBox(
                        height: 24,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tagList.length,
                          itemBuilder: (context, idx) {
                            final tag = tagList[idx];
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
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
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onArrowTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  color: Colors.black.withOpacity(0.44),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- [핫한 유저] 프로필 위젯 (클릭시 상세 팝업) --------------------
  Widget _buildUser(
    String imageUrl,
    String name,
    int likes, {
    String tag = "#기본태그",
    String bio = "자기소개 텍스트",
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.55),
            barrierDismissible: true,
            barrierLabel: '',
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
            transitionBuilder: (context, anim1, anim2, child) {
              final curved = Curves.easeOutBack.transform(anim1.value);
              return Transform.translate(
                offset: Offset(0, (1 - curved) * 700),
                child: Opacity(
                  opacity: anim1.value,
                  child: Center(
                    child: UserDetailPopup(
                      imageUrl: imageUrl,
                      name: name,
                      likes: likes,
                      tag: tag,
                      bio: bio,
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontSize: 14)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 2),
                Text("$likes", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
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
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: const Text(
              "더보기 >",
              style: TextStyle(color: Color.fromARGB(255, 36, 36, 36)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
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
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
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
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 26, bottom: 8),
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
                    const Spacer(),
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
                            children: const [
                              Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Likes",
                                style: TextStyle(
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
                                onPressed: () {},
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
                                onPressed: () {},
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
                        const SizedBox(height: 10),
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
