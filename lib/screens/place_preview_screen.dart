import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// 테마 파일이 없으므로 임시로 색상 정의
class theme {
  static const kTextPrimary = Color(0xFF1F2937);
  static const kTextMuted = Color(0xFF6B7280);
  static const kPageBg = Colors.white;
  static const kDivider = Color(0xFFE5E7EB);
}

class PlacePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> placeData;

  const PlacePreviewScreen({super.key, required this.placeData});

  @override
  State<PlacePreviewScreen> createState() => _PlacePreviewScreenState();
}

class _PlacePreviewScreenState extends State<PlacePreviewScreen> {
  bool _isLiked = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.placeData['isLiked'] ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 장소 정보 템플릿 파싱 함수
  Map<String, String> _parsePlaceTemplate(String content) {
    final Map<String, String> parsedData = {};
    final questions = [
      "이 장소의 매력은 무엇인가요?",
      "어떤 사람에게 추천하나요?",
      "가격대는 어떤가요?",
      "나만의 꿀팁이 있다면?",
    ];

    List<String> lines = content.split('\n');
    String? currentQuestion;

    for (String line in lines) {
      String trimmedLine = line.trim();
      if (questions.contains(trimmedLine)) {
        currentQuestion = trimmedLine;
        parsedData[currentQuestion] = ''; // 질문을 키로 초기화
      } else if (currentQuestion != null && trimmedLine.isNotEmpty) {
        final cleaned = trimmedLine
            .replaceFirst(RegExp(r'^[-•]\s*'), '')
            .trim();
        if (cleaned.isNotEmpty) {
          parsedData[currentQuestion] =
              (parsedData[currentQuestion]! + cleaned + '\n').trim();
        }
      }
    }
    return parsedData;
  }

  /// 템플릿의 각 섹션을 그리는 위젯
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ▼▼▼▼▼ [수정] 아이콘 정렬 및 크기 조절 ▼▼▼▼▼
          SizedBox(
            width: 28,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FaIcon(
                icon,
                size: (icon == FontAwesomeIcons.userFriends) ? 18 : 20,
                color: theme.kTextMuted,
              ),
            ),
          ),
          // ▲▲▲▲▲ [수정] 아이콘 정렬 및 크기 조절 ▲▲▲▲▲
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: theme.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: theme.kTextPrimary,
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
    final List<Uint8List> images = widget.placeData['images'] ?? [];
    final String title =
        (widget.placeData['name'] as String?)?.trim().isEmpty ?? true
        ? "장소 이름"
        : widget.placeData['name'];
    final String category = widget.placeData['category'] ?? "기타";
    final String content = widget.placeData['content'] ?? "";
    final bool useTemplate = widget.placeData['templateUsed'] ?? false;
    final parsedContent = useTemplate ? _parsePlaceTemplate(content) : null;

    return Scaffold(
      backgroundColor: theme.kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: theme.kTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "장소 정보",
          style: TextStyle(
            color: theme.kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: FaIcon(
              _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: _isLiked ? Colors.red : theme.kTextPrimary,
              size: 20,
            ),
            onPressed: () => setState(() => _isLiked = !_isLiked),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 캐러셀 또는 플레이스홀더
            if (images.isNotEmpty)
              SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.memory(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                    if (images.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: images.length,
                          effect: const WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            dotColor: Colors.white70,
                            activeDotColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 280,
                color: const Color(0xFFE5E7EB),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.kTextMuted.withOpacity(0.6),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.question_mark_rounded,
                          color: theme.kTextMuted.withOpacity(0.6),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 2. 제목 및 콘텐츠 영역
            Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 12),
                  // 카테고리, 조회수, 좋아요
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.kTextMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const FaIcon(
                        FontAwesomeIcons.eye,
                        size: 14,
                        color: theme.kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "0",
                        style: TextStyle(fontSize: 13, color: theme.kTextMuted),
                      ),
                      const SizedBox(width: 12),
                      const FaIcon(
                        FontAwesomeIcons.solidHeart,
                        size: 14,
                        color: Color(0xFFFF4D4D),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "0",
                        style: TextStyle(fontSize: 13, color: theme.kTextMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. 템플릿 또는 일반 텍스트
                  if (useTemplate && parsedContent != null) ...[
                    _buildSection(
                      icon: FontAwesomeIcons.file,
                      title: "이 장소의 매력은 무엇인가요?",
                      content: parsedContent["이 장소의 매력은 무엇인가요?"] ?? "",
                    ),
                    _buildSection(
                      icon: FontAwesomeIcons.userFriends,
                      title: "어떤 사람에게 추천하나요?",
                      content: parsedContent["어떤 사람에게 추천하나요?"] ?? "",
                    ),
                    _buildSection(
                      icon: FontAwesomeIcons.tag,
                      title: "가격대는 어떤가요?",
                      content: parsedContent["가격대는 어떤가요?"] ?? "",
                    ),
                    _buildSection(
                      icon: FontAwesomeIcons.star,
                      title: "나만의 꿀팁이 있다면?",
                      content: parsedContent["나만의 꿀팁이 있다면?"] ?? "",
                    ),
                  ] else
                    Text(
                      content.trim().isEmpty ? "작성된 내용이 없습니다." : content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: theme.kTextPrimary,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 4. 위치
                  const Text(
                    "위치",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "지도 표시 영역",
                      style: TextStyle(color: theme.kTextMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
