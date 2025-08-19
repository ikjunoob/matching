import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'ask_for_common.dart' as theme;
import 'application_form_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PostPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onApply; // 외부에서 지원하기 연결할 수 있게 콜백 허용

  const PostPreviewScreen({super.key, required this.post, this.onApply});

  @override
  State<PostPreviewScreen> createState() => _PostPreviewScreenState();
}

class _PostPreviewScreenState extends State<PostPreviewScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post['isLiked'] ?? false;
    _likeCount = widget.post['likes'] ?? 0;
    _viewCount = widget.post['views'] ?? 0;
  }

  String _formatRemain(DateTime d) {
    final now = DateTime.now();
    if (!d.isAfter(now)) return "마감됨";
    final diff = d.difference(now);

    if (diff.inDays >= 1) {
      return "D - ${diff.inDays}";
    }

    // ✅ 하루 미만 남았다면 그냥 D-day로 표시
    return "D - day";
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.55),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Map<String, List<String>> _parseTemplate(String content) {
    final keys = ["모집 대상", "활동 내용", "필요 역량", "추가 정보"];
    final map = {for (final k in keys) k: <String>[]};

    final lines = content.split('\n').map((e) => e.trimRight()).toList();
    String? current;

    bool isHeader(String line) => keys.any((k) => line.startsWith(k));

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (isHeader(line)) {
        current = keys.firstWhere((k) => line.startsWith(k));
        continue;
      }
      if (current != null) {
        final cleaned = line.replaceFirst(RegExp(r'^[-•]\s*'), '').trim();
        if (cleaned.isNotEmpty && !isHeader(line)) {
          map[current]!.add(cleaned);
        }
      }
    }
    return map;
  }

  bool _looksLikeTemplate(String content) {
    const must = ["모집 대상", "활동 내용", "필요 역량", "추가 정보"];
    return must.every((k) => content.contains(k));
  }

  Widget _sectionRow({
    IconData? iconRegular,
    String? customIconAsset,
    double customIconSize = 22,
    double faIconSize = 18,
    required String title,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    Widget leading() {
      if (customIconAsset != null) {
        return Image.asset(
          customIconAsset,
          width: customIconSize,
          height: customIconSize,
          fit: BoxFit.contain,
        );
      }
      if (iconRegular != null) {
        return FaIcon(iconRegular, size: faIconSize, color: theme.kTextPrimary);
      }
      return const SizedBox.shrink();
    }

    final text = items.join('\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (customIconAsset != null ? customIconSize : faIconSize) + 6,
            child: leading(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: theme.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text.isEmpty ? "—" : text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: theme.kTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.post['image'];
    final Uint8List? imageBytes = img is Uint8List ? img : null;
    final String? imageUrl = img is String ? img : null;

    final deadline = widget.post['deadlineAt'] as DateTime?;
    final headcount = widget.post['headcount']?.toString() ?? '';
    final tags = widget.post['tags'] as List? ?? [];
    final content = (widget.post['content'] ?? '') as String;
    final title = ((widget.post['title'] as String?) ?? '').trim().isEmpty
        ? "제목 없음"
        : widget.post['title'];

    final useTemplate = _looksLikeTemplate(content);
    final parsed = useTemplate
        ? _parseTemplate(content)
        : const <String, List<String>>{};

    const double imageHeight = 256;

    return Scaffold(
      backgroundColor: theme.kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: theme.kTextPrimary),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: theme.kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
            ), // ← 오른쪽 여백 줄여서 아이콘을 살짝 왼쪽으로
            child: IconButton(
              icon: FaIcon(
                _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                color: _isLiked ? Colors.red : theme.kTextPrimary,
                size: 20,
              ),
              onPressed: () => setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              }),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 상단 이미지
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageBytes != null)
                  Image.memory(imageBytes, fit: BoxFit.cover)
                else if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(imageUrl, fit: BoxFit.cover)
                else
                  Container(color: const Color(0xFFF2F4F7)),
                if (deadline != null)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: _pill(_formatRemain(deadline)),
                  ),
                if (headcount.isNotEmpty)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _pill("$headcount명 모집"),
                  ),
              ],
            ),
          ),

          // 본문
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 (본문에도 한번 더 — 디자인 유지용)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // 태그 + 메타
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ⬇ 태그들을 감싸는 하나의 라운드 박스
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 240, 240, 240),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children:
                                (tags.isNotEmpty ? tags : const <String>[])
                                    .map(
                                      (t) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 0,
                                        ),
                                        child: Text(
                                          "#$t",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1F2937),
                                            height: 1.0,
                                            fontWeight: FontWeight.w500, // ← 추가
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 조회수
                    const FaIcon(
                      FontAwesomeIcons.solidEye,
                      size: 14,
                      color: Color.fromARGB(255, 75, 75, 75),
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

                    // 좋아요
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

                const SizedBox(height: 20),

                if (useTemplate) ...[
                  _sectionRow(
                    iconRegular: FontAwesomeIcons.addressCard,
                    title: "모집 대상",
                    items: parsed["모집 대상"] ?? const [],
                  ),
                  _sectionRow(
                    iconRegular: FontAwesomeIcons.fileLines,
                    title: "활동 내용",
                    items: parsed["활동 내용"] ?? const [],
                  ),
                  _sectionRow(
                    iconRegular: FontAwesomeIcons.circleCheck,
                    title: "필요 역량",
                    items: parsed["필요 역량"] ?? const [],
                  ),
                  _sectionRow(
                    customIconAsset: "assets/icons/free-icon-info.png",
                    customIconSize: 20,
                    title: "추가 정보",
                    items: parsed["추가 정보"] ?? const [],
                  ),
                ] else ...[
                  Text(
                    content.isEmpty ? "내용이 없습니다." : content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: theme.kTextPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // 외부 콜백이 들어오면 우선 사용
              if (widget.onApply != null) {
                widget.onApply!.call();
                return;
              }
              // 기본 동작: 지원서로 이동
              final qs =
                  (widget.post['questions'] as List?)?.cast<String>() ??
                  const <String>[];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ApplicationFormScreen(post: widget.post, questions: qs),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.kAccent,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "지원하기",
              style: GoogleFonts.notoSansKr(
                fontSize: 20,
                fontWeight: FontWeight.w600, // 진짜 Black 웨이트 다운로드됨
                color: const Color.fromARGB(255, 37, 37, 37),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
