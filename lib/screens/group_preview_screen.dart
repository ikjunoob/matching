// group_preview_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'ask_for_common.dart' as theme;

class GroupPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupPreviewScreen({super.key, required this.group});

  @override
  State<GroupPreviewScreen> createState() => _GroupPreviewScreenState();
}

class _GroupPreviewScreenState extends State<GroupPreviewScreen> {
  late int _viewCount;
  late int _likeCount;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _viewCount = widget.group['views'] ?? 0;
    _likeCount = widget.group['likes'] ?? 0;
    _liked = widget.group['isLiked'] ?? false;
  }

  List<String> get _rules =>
      (widget.group['rules'] as List?)?.cast<String>() ?? const <String>[];

  @override
  Widget build(BuildContext context) {
    final title = (widget.group['title'] as String?)?.trim().isEmpty != true
        ? widget.group['title']
        : "모임";
    final category = widget.group['category'] ?? "기타";
    final intro = widget.group['intro'] ?? "";
    final schedule = widget.group['schedule'] ?? "";
    final place = widget.group['place'] ?? "";
    final plan = widget.group['plan'] ?? "";

    final img = widget.group['image'];
    final Uint8List? bytes = img is Uint8List ? img : null;
    final String? imageUrl = img is String ? img : null;

    final int memberCnt = widget.group['memberCount'] ?? 1;
    final int memberLimit = widget.group['memberLimit'] ?? 15;

    return Scaffold(
      backgroundColor: theme.kPageBg,
      appBar: AppBar(
        backgroundColor: theme.kWhite,
        elevation: 0,
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
          "$title",
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: theme.kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        flexibleSpace: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: theme.kDivider),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _liked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: _liked ? Colors.red : theme.kTextPrimary,
              size: 20,
            ),
            onPressed: () => setState(() {
              _liked = !_liked;
              _likeCount += _liked ? 1 : -1;
              if (_likeCount < 0) _likeCount = 0;
            }),
          ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 상단 이미지
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
                // 제목 + 카테고리 칩
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$title",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.kTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: theme.kDivider),
                      ),
                      child: Text(
                        "$category",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.kTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 인원/뷰/좋아요 메타
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.user,
                      size: 14,
                      color: Color(0xFF1F2937),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$memberCnt / $memberLimit",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const FaIcon(
                      FontAwesomeIcons.solidEye,
                      size: 14,
                      color: Color(0xFF4B4B4B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$_viewCount",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const FaIcon(
                      FontAwesomeIcons.solidHeart,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$_likeCount",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                      const Expanded(
                        child: Text(
                          "김지수",
                          style: TextStyle(
                            color: theme.kTextPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // 연두색 1:1 문의
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: const Color(0xFFE8F7EC), // 연두색 배경
                          foregroundColor: const Color(0xFF2F9E44), // 연한 초록 텍스트
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "1:1 문의",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
