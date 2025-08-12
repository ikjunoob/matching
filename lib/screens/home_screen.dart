import 'package:flutter/material.dart';
import 'notification_screen.dart'; // 알림(Notifications) 화면 연결용
// Remix 아이콘 사용을 위한 패키지
import 'chat_list_screen.dart'; // 채팅 리스트 화면 연결용
import 'dart:ui';
import 'ask_for_screen.dart'; // 새롭게 추가한 '구해요' 탭 화면
import 'post_screen.dart'; // 새롭게 추가한 '게시글 작성' 화면
// CalendarScreen import

// -------------------- HomeScreen: 메인 홈화면 전체를 담당하는 클래스 --------------------
class HomeScreen extends StatefulWidget {
  final int tabIndex; // 부모에서 받아오는 선택된 탭 인덱스 (기본값 0)
  final void Function(int tabIndex)? onTabChange; // 탭 변경시 호출되는 콜백

  const HomeScreen({super.key, this.tabIndex = 0, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// -------------------- HomeScreen의 State (실제 화면/이벤트 처리) --------------------
class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTabIndex;
  final List tabs = ['추천', '모임', '구해요', '장소']; // 상단 탭바에 들어갈 탭 이름

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      setState(() {
        _selectedTabIndex = widget.tabIndex;
      });
    }
  }

  // [함수] 탭 클릭 시 처리
  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    widget.onTabChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // -------------------- 앱 상단 AppBar 부분 --------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // [좌측] 앱 로고 텍스트 ("CC,")
                const SizedBox(width: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8), // 위아래 여백
                  child: Image.asset(
                    'assets/icons/main_logo.png',
                    height: 80, // 로고 크기
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(child: Container()), // 오른쪽 아이콘과의 거리 확보
                // [우측] 채팅 아이콘 (말풍선 아이콘)
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

                // [우측] 알림 아이콘 (종 모양 아이콘)
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 26),
                  tooltip: '알림',
                  onPressed: () {
                    // 알림 화면으로 이동
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
      // -------------------- 앱 전체 본문 --------------------
      body: Column(
        children: [
          // [상단] 탭 바 (추천/모임/구해요/장소)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => _onTabTap(index),
                    child: Column(
                      children: [
                        // 탭 이름(텍스트)
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 탭 선택시 밑줄 애니메이션
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: isSelected ? 24 : 0,
                          color: isSelected
                              ? const Color(0xFFAED6F1)
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // [중앙] 각 탭별 실제 컨텐츠 영역 (아래 함수에서 결정)
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedTabIndex == 0) {
                  return _buildRecommendTab(); // 추천 탭
                } else if (_selectedTabIndex == 1) {
                  return const Center(child: Text("모임 탭 더미"));
                } else if (_selectedTabIndex == 2) {
                  return const AskForScreen();
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

  // -------------------- [추천] 탭 화면 구성 (카드, 장소, 핫한 유저) --------------------
  Widget _buildRecommendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // [추천 모임] 섹션 타이틀
          SectionTitle(title: "✨ 이런 모임은 어때요?", onMoreTap: () => _onTabTap(1)),
          const SizedBox(height: 8),
          // [추천 모임] 카드 리스트 (가로 스크롤)
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
                  onArrowTap: () => print("함께 성장하는 독서 모임: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "주말엔 브런치",
                  tags: "#맛집 #취향공유",
                  heartCount: 88,
                  onArrowTap: () => print("주말엔 브런치: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "토요일엔 스터디/기타 긴 이름 예시",
                  tags: "#스터디 #개발 #네트워킹",
                  heartCount: 77,
                  onArrowTap: () => print("토요일엔 스터디/기타 긴 이름 예시: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=600&q=80',
                  title: "문화 탐방 모임",
                  tags: "#전시 #문화생활",
                  heartCount: 65,
                  onArrowTap: () => print("문화 탐방 모임: 상세 준비중"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // [추천 장소] 섹션 타이틀
          SectionTitle(title: "🎯 취향저격! 추천 장소", onMoreTap: () => _onTabTap(3)),
          const SizedBox(height: 8),
          // [추천 장소] 카드 리스트 (가로 스크롤)
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1508264165352-258db2ebd59b?auto=format&fit=crop&w=8',
                  title: "별 보러 가는 언덕",
                  tags: "#자연 #밤하늘",
                  heartCount: 95,
                  onArrowTap: () => print("별 보러 가는 언덕: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
                _buildCard(
                  image:
                      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?auto=format&fit=crop&w=80',
                  title: "조용한 카페",
                  tags: "#공부 #카페 #스터디",
                  heartCount: 76,
                  onArrowTap: () => print("조용한 카페: 상세 준비중"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // [핫한 유저] 섹션 타이틀
          const SectionTitle(title: "🔥 지금 가장 핫한 유저"),
          const SizedBox(height: 20),
          // [하단] 핫한 유저 프로필 리스트 (3명, 가로 Row)
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

  // -------------------- 카드형 콘텐츠 위젯(모임/장소 등 가로 슬라이드) --------------------
  Widget _buildCard({
    required String image,
    required String title,
    required String tags,
    required int heartCount,
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
          // 카드 이미지 위에 그라데이션 오버레이
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
          // [상단] 인원/좋아요 아이콘과 숫자
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                // 인원 표시
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
                        "5/10명",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // 좋아요(하트) 표시
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
          // [하단 좌측] 타이틀/태그
          Positioned(
            left: 10,
            bottom: 10,
            right: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카드 타이틀
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
                // 카드 태그(#태그 형식)
                tagList.length <= 2
                    ? Wrap(
                        spacing: 6,
                        children: tagList
                            .where((tag) => tag.isNotEmpty)
                            .map(
                              (tag) => Container(
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
                            )
                            .toList(),
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
          // [하단 우측] → 이동 화살표 버튼
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

  // -------------------- [핫한 유저] 프로필 위젯(클릭시 상세 팝업) --------------------
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
        // [핫한 유저] 프로필 클릭 시 → 상세 팝업 표시
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.55), // 뒤 배경 반투명 검정
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
            // [유저 프로필 사진]
            ClipOval(
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
            const SizedBox(height: 4),
            // [유저 닉네임]
            Text(name, style: const TextStyle(fontSize: 14)),
            // [유저 좋아요(하트) 수]
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
              // 1. 배경: 사용자 이미지 + 블러 효과 (Glassmorphism)
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
              // 2. 콘텐츠: 프로필 정보, 자기소개, 버튼 등
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // --- 상단: 프로필 사진, 닉네임, 태그 ---
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        // 프로필 이미지
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
                        // ✅ 유저 이름 (검은 pill 박스)
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
                        // ✅ 태그 (검은 pill 박스)
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
                    // --- 중앙: 자기소개 (검은 pill 박스) ---
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
                    // --- 하단: 좋아요 수, CTA 버튼 ---
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
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$likes Likes",
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
                                  print("$name 프로필 보기 클릭");
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
                                  print("$name 채팅하기 클릭");
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

// -------------------- 각 섹션별 타이틀 & "더보기" 버튼 위젯 --------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionTitle({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // [타이틀 텍스트]
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // ["더보기 >" 버튼]
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Text(
              "더보기 >",
              style: TextStyle(color: const Color.fromARGB(255, 36, 36, 36)),
            ),
          ),
      ],
    );
  }
}
