// place_preview_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'place_review_write_screen.dart';

class theme {
  static const kTextPrimary = Color(0xFF1F2937);
  static const kTextMuted = Color(0xFF6B7280);
  static const kPageBg = Colors.white;
  static const kDivider = Color(0xFFE5E7EB);
  static const kAccent = Color(0xFF5BA7FF);
}

class PlacePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> placeData;
  final bool isPreview;

  const PlacePreviewScreen({
    super.key,
    required this.placeData,
    this.isPreview = false,
  });

  @override
  State<PlacePreviewScreen> createState() => _PlacePreviewScreenState();
}

class _PlacePreviewScreenState extends State<PlacePreviewScreen> {
  bool _isLiked = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late List<Map<String, dynamic>> _reviews;
  late int _commentsCount;
  late int _viewsCount;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.placeData['isLiked'] ?? false;

    final rawReviews = widget.placeData['reviews'];
    if (rawReviews is List) {
      _reviews = rawReviews
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      _reviews = <Map<String, dynamic>>[];
    }

    final meta = widget.placeData['meta'];
    if (meta is Map) {
      _commentsCount = (meta['comments'] ?? _reviews.length) as int;
      _viewsCount = (meta['views'] ?? 0) as int;
      _likesCount = (meta['likes'] ?? 0) as int;
    } else {
      _commentsCount = _reviews.length;
      _viewsCount = (widget.placeData['views'] ?? 0) as int;
      _likesCount = (widget.placeData['likes'] ?? 0) as int;
    }

    _pageController.addListener(() {
      final p = _pageController.page;
      if (p != null) {
        final idx = p.round();
        if (idx != _currentPage && mounted) {
          setState(() => _currentPage = idx);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, String> _parsePlaceTemplate(String content) {
    final Map<String, String> parsedData = {};
    const questions = [
      "이 장소의 매력은 무엇인가요?",
      "어떤 사람에게 추천하나요?",
      "가격대는 어떤가요?",
      "나만의 꿀팁이 있다면?",
    ];
    for (final q in questions) {
      parsedData[q] = "";
    }
    final lines = content.split('\n');
    String? current;
    for (final raw in lines) {
      final line = raw.trim();
      if (questions.contains(line)) {
        current = line;
      } else if (current != null && line.isNotEmpty) {
        final cleaned = line.replaceFirst(RegExp(r'^[-•]\s*'), '').trim();
        if (cleaned.isNotEmpty) {
          parsedData[current] = (parsedData[current]!.isEmpty
              ? cleaned
              : '${parsedData[current]}\n$cleaned');
        }
      }
    }
    return parsedData;
  }

  bool _looksLikeTemplate(String content) {
    const keys = [
      "이 장소의 매력은 무엇인가요?",
      "어떤 사람에게 추천하나요?",
      "가격대는 어떤가요?",
      "나만의 꿀팁이 있다면?",
    ];
    return keys.every((k) => content.contains(k));
  }

  Widget _section({
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
          SizedBox(
            width: 28,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FaIcon(icon, size: 18, color: theme.kTextMuted),
            ),
          ),
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

  String _dateStr(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

  Widget _stars(int rating, {double size = 14}) {
    return Row(
      children: List.generate(
        5,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: FaIcon(
            i < rating ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
            size: size,
            color: const Color(0xFFFFB300),
          ),
        ),
      ),
    );
  }

  Future<void> _openReviewWriter(String placeTitle) async {
    if (widget.isPreview) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("미리보기에서는 리뷰 작성이 비활성화되어 있어요.")),
      );
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceReviewWriteScreen(placeTitle: placeTitle),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _reviews.insert(0, result);
      _commentsCount = _commentsCount + 1;
    });
  }

  // === 더미 주소 생성기: 제목 기반으로 안정적 선택 ===
  String _dummyAddressFrom(String seed) {
    const samples = [
      '서울특별시 강남구 테헤란로 123',
      '서울특별시 관악구 대학동 11-1',
      '서울특별시 마포구 양화로 45',
      '경기도 성남시 분당구 판교역로 235',
      '부산광역시 해운대구 센텀중앙로 55',
      '대구광역시 수성구 달구벌대로 1234',
      '광주광역시 북구 첨단과기로 99',
      '대전광역시 유성구 대학로 291',
      '인천광역시 연수구 송도과학로 16',
      '제주특별자치도 제주시 첨단로 242',
    ];
    final s = (seed.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : seed.hashCode);
    final idx = s.abs() % samples.length;
    return samples[idx];
  }

  // 이미지 소스 수집: 바이트/URL 다 지원 + 단일 'image' 키도 포함
  List<dynamic> _gatherImages(Map<String, dynamic> data) {
    final List<dynamic> out = [];

    // 1) images: [...]
    final raw = data['images'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Uint8List) out.add(e);
        if (e is String && e.trim().isNotEmpty) out.add(e.trim());
      }
    }

    // 2) 단일 image / cover / thumb / coverImage
    for (final key in const ['image', 'cover', 'thumb', 'coverImage']) {
      final v = data[key];
      if (v is Uint8List) out.insert(0, v);
      if (v is String && v.trim().isNotEmpty) out.insert(0, v.trim());
    }

    // 3) imageUrls / photos 같은 URL 배열
    for (final key in const ['imageUrls', 'photos']) {
      final v = data[key];
      if (v is List) {
        for (final e in v) {
          if (e is String && e.trim().isNotEmpty) out.add(e.trim());
        }
      }
    }

    // URL 중복 제거(바이트는 유지)
    final seen = <String>{};
    final dedup = <dynamic>[];
    for (final e in out) {
      if (e is String) {
        if (seen.add(e)) dedup.add(e);
      } else {
        dedup.add(e);
      }
    }
    return dedup;
  }

  // === 이미지 위에 얹는 주소 배지(반투명) ===
  Widget _addressPill(BuildContext context, String text) {
    final maxW = MediaQuery.of(context).size.width * 0.72;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.55),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.locationDot,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageWidget(dynamic src) {
    if (src is Uint8List) {
      return Image.memory(src, fit: BoxFit.cover, width: double.infinity);
    } else if (src is String) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFE5E7EB),
          alignment: Alignment.center,
          child: const Text(
            "이미지를 불러오지 못했어요",
            style: TextStyle(color: theme.kTextMuted),
          ),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: const Text(
          "이미지가 없습니다.",
          style: TextStyle(color: theme.kTextMuted),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = _gatherImages(widget.placeData);

    final String title =
        (widget.placeData['name'] as String?)?.trim().isEmpty ?? true
        ? "장소 이름"
        : widget.placeData['name'];
    final String category = widget.placeData['category'] ?? "기타";
    final String content = widget.placeData['content'] ?? "";

    // 주소/위치 문자열 + 비어있으면 제목 기반 더미 생성
    final String addressRaw =
        ((widget.placeData["address"] ?? widget.placeData["location"]) ?? "")
            .toString()
            .trim();
    final String address = addressRaw.isNotEmpty
        ? addressRaw
        : _dummyAddressFrom(title);

    final bool useTemplate =
        (widget.placeData['templateUsed'] ?? false) ||
        _looksLikeTemplate(content);
    final parsed = useTemplate ? _parsePlaceTemplate(content) : null;

    return Scaffold(
      backgroundColor: theme.kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: theme.kTextPrimary),
          onPressed: () => Navigator.maybePop(context),
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
            onPressed: () => setState(() {
              _isLiked = !_isLiked;
              _likesCount += _isLiked ? 1 : -1;
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.kAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _openReviewWriter(title),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.solidCommentDots, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "리뷰 쓰기",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return _imageWidget(images[index]);
                      },
                    ),
                    if (images.length > 1) ...[
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Opacity(
                            opacity: _currentPage == 0 ? 0.35 : 0.9,
                            child: IgnorePointer(
                              ignoring: _currentPage == 0,
                              child: InkWell(
                                onTap: () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.chevronLeft,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Opacity(
                            opacity: _currentPage == images.length - 1
                                ? 0.35
                                : 0.9,
                            child: IgnorePointer(
                              ignoring: _currentPage == images.length - 1,
                              child: InkWell(
                                onTap: () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 12,
                        child: Center(
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
                      ),
                    ],
                    // 주소 배지: 좌하단 (더미 포함)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _addressPill(context, address),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 280,
                color: const Color(0xFFE5E7EB),
                child: const Center(child: Text("이미지가 없습니다.")),
              ),

            // ===== 본문 =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.kDivider),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: theme.kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const FaIcon(
                        FontAwesomeIcons.solidCommentDots,
                        size: 13,
                        color: theme.kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$_commentsCount",
                        style: const TextStyle(
                          fontSize: 12,
                          color: theme.kTextMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const FaIcon(
                        FontAwesomeIcons.solidEye,
                        size: 13,
                        color: theme.kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$_viewsCount",
                        style: const TextStyle(
                          fontSize: 12,
                          color: theme.kTextMuted,
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
                        "$_likesCount",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 템플릿/일반 본문
                  if (useTemplate && parsed != null) ...[
                    _section(
                      icon: FontAwesomeIcons.fileLines,
                      title: "이 장소의 매력은 무엇인가요?",
                      content: parsed["이 장소의 매력은 무엇인가요?"] ?? "",
                    ),
                    _section(
                      icon: FontAwesomeIcons.user,
                      title: "어떤 사람에게 추천하나요?",
                      content: parsed["어떤 사람에게 추천하나요?"] ?? "",
                    ),
                    _section(
                      icon: FontAwesomeIcons.tags,
                      title: "가격대는 어떤가요?",
                      content: parsed["가격대는 어떤가요?"] ?? "",
                    ),
                    _section(
                      icon: FontAwesomeIcons.star,
                      title: "나만의 꿀팁이 있다면?",
                      content: parsed["나만의 꿀팁이 있다면?"] ?? "",
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
                  const SizedBox(height: 24),
                  const Divider(color: theme.kDivider, height: 1),
                  const SizedBox(height: 16),

                  Text(
                    "리뷰 (${_reviews.length})",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 16),
                      child: Text(
                        "아직 리뷰가 없습니다.",
                        style: TextStyle(color: theme.kTextMuted, fontSize: 14),
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: _reviews.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final r = _reviews[i];
                        final author = (r['author'] ?? '익명').toString();
                        final rating = (r['rating'] ?? 5) as int;
                        final body = (r['content'] ?? '').toString();
                        final dt = (r['createdAt'] is DateTime)
                            ? r['createdAt'] as DateTime
                            : DateTime.now();
                        final initial = author.isNotEmpty
                            ? author.characters.first.toUpperCase()
                            : "?";

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 237, 244, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.kTextPrimary.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: theme.kTextPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            author,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: theme.kTextPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _dateStr(dt),
                                          style: const TextStyle(
                                            color: theme.kTextMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    _stars(rating, size: 13),
                                    const SizedBox(height: 6),
                                    Text(
                                      body,
                                      style: const TextStyle(
                                        color: theme.kTextPrimary,
                                        fontSize: 14,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
