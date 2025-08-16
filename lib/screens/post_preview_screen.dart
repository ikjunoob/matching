// post_preview_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ===== Design Tokens =====
const kAccent = Color(0xFF5BA7FF);
const kPageBg = Color(0xFFF9FAFB);
const kCardBg = Color(0xFFFFFFFF);
const kTextPrimary = Color(0xFF374151); // 살짝 연한 검은색
const kTextMuted = Color(0xFF6B7280);
const kIconMuted = Color(0xFF9CA3AF);
const kTagGrey = Color(0xFF9CA3AF);
const kDDayBg = Color.fromRGBO(0, 0, 0, 0.55);

class PostPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostPreviewScreen({super.key, required this.post});

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
    if (diff.inDays >= 1) return "D-${diff.inDays}";
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return "마감까지 $h시간 $m분";
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kDDayBg,
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
    required IconData iconRegular,
    required String title,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    const double iconSlot = 22;
    final text = items.join('\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: iconSlot,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: FaIcon(iconRegular, size: 18, color: kTextPrimary),
              ),
            ),
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
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text.isEmpty ? "—" : text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: kTextMuted,
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
    final Uint8List? imageBytes = widget.post['image'] as Uint8List?;
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
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: kCardBg,
        elevation: 0.5,
        shadowColor: Colors.black12,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : kTextPrimary,
            ),
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              });
            },
          ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 이미지
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageBytes != null)
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  )
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

          // 본문 (패딩 적용)
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
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // 태그 + 메타
                Row(
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: (tags.isNotEmpty ? tags : const <String>[])
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    "#$t",
                                    style: const TextStyle(
                                      color: kTagGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FaIcon(
                      FontAwesomeIcons.eye,
                      size: 16,
                      color: kIconMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$_viewCount",
                      style: const TextStyle(color: kIconMuted, fontSize: 14),
                    ),
                    const SizedBox(width: 14),
                    const FaIcon(
                      FontAwesomeIcons.solidHeart,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$_likeCount",
                      style: const TextStyle(color: kIconMuted, fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 섹션
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
                    iconRegular: FontAwesomeIcons.circleInfo,
                    title: "추가 정보",
                    items: parsed["추가 정보"] ?? const [],
                  ),
                ] else ...[
                  Text(
                    content.isEmpty ? "내용이 없습니다." : content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: kTextPrimary,
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: kAccent,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "지원하기",
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
