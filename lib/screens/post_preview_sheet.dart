// post_preview_sheet.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

const kAccent = Color(0xFF5BA7FF);
const kPageBg = Color(0xFFF9FAFB);
const kCardBg = Color(0xFFFFFFFF);
const kTextPrimary = Color(0xFF374151);
const kTextMuted = Color(0xFF6B7280);
const kIconMuted = Color(0xFF9CA3AF);
const kTagGrey = Color(0xFF9CA3AF);
const kDDayBg = Color.fromRGBO(0, 0, 0, 0.55);

class PostPreviewSheet extends StatefulWidget {
  final Map<String, dynamic> post;
  final ScrollController scrollController;
  final VoidCallback onApply;

  const PostPreviewSheet({
    super.key,
    required this.post,
    required this.scrollController,
    required this.onApply,
  });

  @override
  State<PostPreviewSheet> createState() => _PostPreviewSheetState();
}

class _PostPreviewSheetState extends State<PostPreviewSheet> {
  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post["isLiked"] ?? false;
    _likeCount = widget.post["likes"] ?? 0;
    _viewCount = widget.post["views"] ?? 0;
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
    final lines = content.split("\n").map((e) => e.trimRight()).toList();
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
        final cleaned = line.replaceFirst(RegExp(r"^[-•]\s*"), "").trim();
        if (cleaned.isNotEmpty && !isHeader(line)) map[current]!.add(cleaned);
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
    String? customIcon,
    double customIconSize = 22,
    double faIconSize = 18,
    required String title,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final double iconSlot = customIcon != null
        ? (customIconSize + 6)
        : (faIconSize + 6);
    final text = items.join("\n");

    Widget leadingIcon() {
      if (customIcon != null) {
        return Image.asset(
          customIcon,
          width: customIconSize,
          height: customIconSize,
        );
      }
      if (iconRegular == null)
        return SizedBox(width: faIconSize, height: faIconSize);
      return FaIcon(iconRegular, size: faIconSize, color: kTextPrimary);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: iconSlot,
            child: Align(alignment: Alignment.topLeft, child: leadingIcon()),
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
    final Uint8List? imageBytes = widget.post["image"] as Uint8List?;
    final deadline = widget.post["deadlineAt"] as DateTime?;
    final headcount = widget.post["headcount"]?.toString() ?? "";
    final tags = (widget.post["tags"] as List?) ?? [];
    final content = (widget.post["content"] ?? "") as String;
    final title = ((widget.post["title"] as String?) ?? "").trim().isEmpty
        ? "제목 없음"
        : widget.post["title"];
    final useTemplate = _looksLikeTemplate(content);
    final parsed = useTemplate
        ? _parseTemplate(content)
        : const <String, List<String>>{};

    return Container(
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // grab handle + header
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                // 이미지
                SizedBox(
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageBytes != null)
                        Image.memory(imageBytes, fit: BoxFit.cover)
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    (tags.isNotEmpty ? tags : const <String>[])
                                        .map(
                                          (t) => Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
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
                            style: const TextStyle(
                              color: kIconMuted,
                              fontSize: 14,
                            ),
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
                            style: const TextStyle(
                              color: kIconMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                          customIcon: "assets/icons/free-icon-info.png",
                          customIconSize: 20,
                          title: "추가 정보",
                          items: parsed["추가 정보"] ?? const [],
                        ),
                      ] else
                        Text(
                          content.isEmpty ? "내용이 없습니다." : content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: kTextPrimary,
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // 하단 CTA
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
          ),
        ],
      ),
    );
  }
}
