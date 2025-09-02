// group_preview_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 이동 대상 화면
import 'chat_list_screen.dart';
import 'notification_screen.dart';

import 'ask_for_common.dart' as theme;

class GroupPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupPreviewScreen({super.key, required this.group});

  @override
  State<GroupPreviewScreen> createState() => _GroupPreviewScreenState();
}

class _GroupPreviewScreenState extends State<GroupPreviewScreen> {
  // 홈 스타일과 맞춘 인디케이터
  static const Color _kIndicator = Color(0xFFAED6F1);
  static const double _kIndicatorHeight = 3;

  late int _viewCount;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _viewCount = widget.group['views'] ?? 0;
    _likeCount = widget.group['likes'] ?? 0;
  }

  List<String> get _rules =>
      (widget.group['rules'] as List?)?.cast<String>() ?? const <String>[];

  List<String> get _tags {
    final raw = (widget.group['tags'] as List?)?.whereType<String>() ?? [];
    return raw
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.startsWith('#') ? t : '#$t')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.group['title'] as String?)?.trim().isNotEmpty == true
        ? widget.group['title'] as String
        : "모임";
    final category =
        (widget.group['category'] as String?)?.trim().isNotEmpty == true
        ? widget.group['category'] as String
        : "기타";
    final intro = widget.group['intro'] ?? "";
    final schedule = widget.group['schedule'] ?? "";
    final place = widget.group['place'] ?? "";
    final plan = widget.group['plan'] ?? "";

    final img = widget.group['image'];
    final Uint8List? bytes = img is Uint8List ? img : null;
    final String? imageUrl = img is String ? img : null;

    final int memberCnt = widget.group['memberCount'] ?? 1;
    final int memberLimit = widget.group['memberLimit'] ?? 15;

    return DefaultTabController(
      length: 4,
      initialIndex: 0, // "소모임 소개" 고정
      child: Scaffold(
        backgroundColor: theme.kPageBg,
        appBar: AppBar(
          backgroundColor: theme.kWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              size: 21,
              color: theme.kTextPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: theme.kTextPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          // ✅ 우측: 채팅/알림 아이콘 (CommonHeader와 동일 동작)
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              },
              tooltip: '메시지',
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
              tooltip: '알림',
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF6B7280),
                size: 28,
              ),
            ),
            const SizedBox(width: 6),
          ],
          // ▶ 탭: 화면 폭의 86%만 사용해서 더 모여 보이게 + 가운데 정렬
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * 0.86; // 더 붙이고 싶으면 0.82 등으로
                return Center(
                  child: SizedBox(
                    width: width,
                    child: TabBar(
                      isScrollable: false, // 등분 유지
                      labelPadding: EdgeInsets.zero, // 내부 여백 최소화
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: theme.kAccent,
                          width: _kIndicatorHeight,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorPadding: EdgeInsets.zero,
                      labelColor: theme.kTextPrimary,
                      unselectedLabelColor: theme.kTextMuted,
                      // ↓ 글자 크기 살짝 축소(요청 반영)
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                      ),
                      overlayColor: const MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                      tabs: const [
                        Tab(text: "소모임 소개"),
                        Tab(text: "게시판"),
                        Tab(text: "정기모임"),
                        Tab(text: "갤러리"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _buildIntroTab(
              bytes: bytes,
              imageUrl: imageUrl,
              title: title,
              tags: _tags,
              category: category,
              memberCnt: memberCnt,
              memberLimit: memberLimit,
              intro: intro,
              schedule: schedule,
              place: place,
              plan: plan,
            ),
            const _DummyTab(label: "게시판", desc: "게시판 콘텐츠는 준비 중입니다."),
            const _DummyTab(label: "정기모임", desc: "정기모임 일정은 곧 공개됩니다."),
            const _DummyTab(label: "갤러리", desc: "사진 갤러리는 차곡차곡 모으는 중!"),
          ],
        ),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.kAccent,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "소모임 가입하기",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- [탭1] 소모임 소개 --------------------
  Widget _buildIntroTab({
    required Uint8List? bytes,
    required String? imageUrl,
    required String title,
    required List<String> tags,
    required String category,
    required int memberCnt,
    required int memberLimit,
    required String intro,
    required String schedule,
    required String place,
    required String plan,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 탭과 이미지 사이 여백/라인 없이 바로 붙도록
        SizedBox(
          height: 256,
          child: (bytes != null)
              ? Image.memory(bytes, fit: BoxFit.cover, width: double.infinity)
              : (imageUrl != null && imageUrl.isNotEmpty)
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Container(color: const Color(0xFFF2F4F7)),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // #태그
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags
                      .map(
                        (t) => Text(
                          t,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: theme.kTextMuted,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
              ],

              // 카테고리 + 인원/조회/좋아요
              Row(
                children: [
                  _CategoryPill(label: category),
                  const SizedBox(width: 10),

                  const FaIcon(
                    FontAwesomeIcons.users,
                    size: 13,
                    color: theme.kTextPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$memberCnt/$memberLimit",
                    style: const TextStyle(
                      fontSize: 12,
                      color: theme.kTextPrimary,
                    ),
                  ),

                  const SizedBox(width: 12),
                  const FaIcon(
                    FontAwesomeIcons.solidEye,
                    size: 13,
                    color: theme.kTextPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$_viewCount",
                    style: const TextStyle(
                      fontSize: 12,
                      color: theme.kTextPrimary,
                    ),
                  ),

                  const SizedBox(width: 12),
                  const FaIcon(
                    FontAwesomeIcons.solidHeart,
                    size: 13,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$_likeCount",
                    style: const TextStyle(
                      fontSize: 12,
                      color: theme.kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 한 줄 소개
              if (intro.toString().trim().isNotEmpty) ...[
                Text(
                  "$intro",
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.45,
                    color: theme.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 모임 정보
              const _SectionTitle("모임 정보"),
              const SizedBox(height: 8),
              _InfoRow(icon: FontAwesomeIcons.calendarAlt, text: "$schedule"),
              const SizedBox(height: 8),
              _InfoRow(icon: FontAwesomeIcons.mapMarkerAlt, text: "$place"),
              const SizedBox(height: 20),

              // 모임 규칙
              const _SectionTitle("모임 규칙"),
              const SizedBox(height: 8),
              if (_rules.isEmpty)
                const Text(
                  "—",
                  style: TextStyle(color: theme.kTextMuted, fontSize: 14.5),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _rules
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "• ",
                                style: TextStyle(
                                  height: 1.45,
                                  color: theme.kTextPrimary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    height: 1.45,
                                    fontSize: 14.5,
                                    color: theme.kTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),

              // 활동 계획
              const _SectionTitle("활동 계획"),
              const SizedBox(height: 8),
              Text(
                plan.toString().trim().isEmpty ? "—" : "$plan",
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: theme.kTextPrimary,
                ),
              ),
              const SizedBox(height: 28),

              // 참여 멤버 + 1:1 문의
              const _SectionTitle("참여 멤버"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.kDivider),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE5E7EB),
                      child: Text(
                        "JP",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.kTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 이름 + 역할(작게, w500)
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "김지수",
                            style: TextStyle(
                              color: theme.kTextPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "모임 리더",
                            style: TextStyle(
                              color: theme.kTextMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        // 내부 여백 (여기 숫자로 위아래 두께 조절)
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        // 🔑 최소 높이/너비 제한 제거 + 터치 타깃 축소
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: 0,
                        ),

                        backgroundColor: const Color(0xFFE8F7EC),
                        foregroundColor: const Color(0xFF2F9E44),
                        textStyle: const TextStyle(
                          fontSize: 11.0, // 글자 크기
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('1:1 문의'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------- 더미 탭 --------------------
class _DummyTab extends StatelessWidget {
  final String label;
  final String desc;
  const _DummyTab({required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "$label\n$desc",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: theme.kTextMuted,
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: theme.kTextPrimary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.kTextPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: theme.kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.kDivider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: theme.kTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
