// lib/screens/application_form_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'ask_for_common.dart';

class ApplicationFormScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<String> questions;

  const ApplicationFormScreen({
    super.key,
    required this.post,
    required this.questions,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _answers;
  late final List<FocusNode> _focusNodes; // 포커스 감지용

  @override
  void initState() {
    super.initState();
    _answers = List.generate(
      widget.questions.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.questions.length, (i) {
      final node = FocusNode();
      node.addListener(() {
        if (mounted) setState(() {});
      });
      return node;
    });
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f
        ..removeListener(() {})
        ..dispose();
    }
    super.dispose();
  }

  // 기본 인풋 데코 (배경/보더만 담당)
  InputDecoration _field({String? hint}) => InputDecoration(
    hintText: hint ?? "답변을 입력하세요...",
    hintStyle: const TextStyle(color: kTextMuted),
    filled: true,
    fillColor: kInputBg, // bg-gray-100 (#F3F4F6)
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: kInputBg), // border-gray-100
      borderRadius: BorderRadius.all(Radius.circular(12)), // rounded-md
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kInputBg),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kAccent, width: 2), // focus cyan (#00FFFF)
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: const EdgeInsets.all(12), // padding 12px
  );

  // 글로우 래퍼: 포커스되면 외곽에 cyan 글로우
  Widget _glowFieldWrapper({required bool isFocused, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFocused
            ? const [
                BoxShadow(
                  color: Color(0x8000FFFF), // 50% 투명 cyan
                  blurRadius: 7,
                  spreadRadius: 1.2,
                  offset: Offset(0, 0),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("지원서가 제출되었습니다.")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String title = (widget.post["title"] as String?) ?? "제목 없음";
    final String content = (widget.post["content"] as String?)?.trim() ?? "";
    final dynamic imageData = widget.post["image"]; // String(URL) 또는 Uint8List

    // 썸네일 48x48, rounded-md
    Widget? imageWidget;
    if (imageData != null) {
      if (imageData is String && imageData.isNotEmpty) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageData,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        );
      } else if (imageData is Uint8List) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageData,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        toolbarHeight: 64, // 헤더 높이 64px
        title: const Text(
          "지원서 작성",
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: kTextPrimary),
      ),
      body: Center(
        // max-width: 768px & 중앙 정렬
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120), // 섹션 여백 24px
              children: [
                // 레이블(박스 밖)
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    "지원할 공고",
                    style: TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                ),

                // 카드 컨테이너
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageWidget != null) imageWidget,
                      if (imageWidget != null) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 내용 (멀티라인, ellipsis)
                            Text(
                              content.isEmpty ? "내용이 없습니다." : content,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: kTextPrimary,
                              ),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 👇 여기 추가: 카드와 같은 폭의 구분선(간격 포함)
                const SizedBox(height: 30),
                const Divider(height: 1, thickness: 1, color: kDivider),
                const SizedBox(height: 24),

                const Text(
                  "질문",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // 각 질문 필드에 글로우 적용
                ...List.generate(widget.questions.length, (i) {
                  final q = widget.questions[i];
                  final node = _focusNodes[i];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == widget.questions.length - 1 ? 0 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${i + 1}. $q",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _glowFieldWrapper(
                          isFocused: node.hasFocus,
                          child: TextFormField(
                            focusNode: node,
                            controller: _answers[i],
                            minLines: 4,
                            maxLines: 8,
                            decoration: _field(hint: "답변을 입력하세요..."),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "답변을 입력해 주세요."
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),

      // 하단 버튼(구분선/섀도우 없이, 페이지와 같은 z-index 느낌)
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "제출하기",
              style: TextStyle(
                fontSize: 16,
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
