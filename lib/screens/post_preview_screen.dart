import 'dart:typed_data';
import 'package:flutter/material.dart';

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
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
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

  Widget _sectionFlat({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final text = items.join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF5BA7FF)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text.isEmpty ? "—" : text,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.5,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? imageBytes = widget.post['image'] as Uint8List?;
    final deadline = widget.post['deadlineAt'] as DateTime?;
    final headcount = widget.post['headcount']?.toString() ?? '';
    final tags = widget.post['tags'] as List? ?? [];
    final content = (widget.post['content'] ?? '') as String;
    final title = (widget.post['title'] as String).isEmpty
        ? "제목 없음"
        : widget.post['title'];

    final bool useTemplate = _looksLikeTemplate(content);
    final parsed = useTemplate
        ? _parseTemplate(content)
        : const <String, List<String>>{};

    // 화면 너비 기반 고정 높이 (16:9 등 원하는 비율로)
    final double w = MediaQuery.of(context).size.width - 32; // 좌우 padding 고려
    final double h = w * 9 / 16; // 16:9. 필요하면 4/3 등으로 변경

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.black,
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
        padding: const EdgeInsets.all(16),
        children: [
          // === 이미지: 가로 꽉 채우기 핵심 ===
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity, // 가로 꽉
              height: h, // 고정 높이(비율 유지용)
              child: Stack(
                fit: StackFit.expand, // 내부 위젯(이미지) 꽉 채우기
                children: [
                  if (imageBytes != null)
                    Image.memory(
                      imageBytes,
                      fit: BoxFit.cover, // 비율 유지하며 잘라서 꽉 채움
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
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              if (tags.isNotEmpty)
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: tags
                        .map(
                          (t) => Text(
                            "#$t",
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.remove_red_eye, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text("$_viewCount"),
              const SizedBox(width: 12),
              Icon(Icons.favorite, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 4),
              Text("$_likeCount"),
            ],
          ),

          const SizedBox(height: 16),

          if (!useTemplate)
            Text(
              content.isEmpty ? "내용이 없습니다." : content,
              style: const TextStyle(fontSize: 16, height: 1.45),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionFlat(
                  icon: Icons.group_rounded,
                  title: "모집 대상",
                  items: parsed["모집 대상"] ?? const [],
                ),
                _sectionFlat(
                  icon: Icons.event_note_rounded,
                  title: "활동 내용",
                  items: parsed["활동 내용"] ?? const [],
                ),
                _sectionFlat(
                  icon: Icons.bolt_rounded,
                  title: "필요 역량",
                  items: parsed["필요 역량"] ?? const [],
                ),
                _sectionFlat(
                  icon: Icons.info_outline_rounded,
                  title: "추가 정보",
                  items: parsed["추가 정보"] ?? const [],
                ),
                if ((parsed.values.fold<int>(0, (a, b) => a + b.length)) == 0)
                  const Text(
                    "템플릿 항목을 입력하면 미리보기에 정리되어 보여집니다.",
                    style: TextStyle(color: Colors.black54),
                  ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BA7FF),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
