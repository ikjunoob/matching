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

  // 컨트롤러는 제거하고, 값은 여기서 관리
  final Map<int, String> _answersData = {};

  // 포커스노드는 글로우용으로 "필요할 때만" 생성
  final Map<int, FocusNode> _focusNodes = {};
  FocusNode _nodeFor(int i) {
    if (_focusNodes[i] != null) return _focusNodes[i]!;
    final node = FocusNode();
    node.addListener(() {
      if (mounted) setState(() {});
    });
    _focusNodes[i] = node;
    return node;
  }

  // ✅ 각 TextFormField의 에러 상태 확인용 키
  final Map<int, GlobalKey<FormFieldState>> _fieldKeys = {};
  GlobalKey<FormFieldState> _formFieldKeyFor(int i) =>
      _fieldKeys.putIfAbsent(i, () => GlobalKey<FormFieldState>());

  @override
  void dispose() {
    for (final f in _focusNodes.values) {
      f
        ..removeListener(() {})
        ..dispose();
    }
    super.dispose();
  }

  InputDecoration _field({String? hint}) => InputDecoration(
    hintText: hint ?? "답변을 입력하세요...",
    hintStyle: const TextStyle(color: kTextMuted),
    filled: true,
    fillColor: kInputBg,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: kInputBg),
      borderRadius: BorderRadius.all(Radius.circular(4)), // ✅ 기본 radius
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kInputBg),
      borderRadius: BorderRadius.all(Radius.circular(4)), // ✅ 평상시 radius
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kAccent, width: 1.6), // ✅ 포커스시 radius
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    // ✅ 에러 상태 보더를 명시적으로 지정
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      borderRadius: const BorderRadius.all(Radius.circular(4)), // ✅ 에러시 radius
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
      borderRadius: const BorderRadius.all(Radius.circular(4)), // ✅ 에러 + 포커스 radius
    ),
    contentPadding: const EdgeInsets.all(12),
  );

  // ✅ 에러일 때는 글로우 제거
  Widget _glowFieldWrapper({
    required bool isFocused,
    required bool hasError,
    required Widget child,
  }) {
    final showGlow = isFocused && !hasError;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: showGlow
            ? const [
                BoxShadow(
                  color: Color(0x3300FFFF), // 20% 투명 cyan (기존 0x80 → 많이 낮춤)
                  blurRadius: 5, // 기존 7 → 낮춤
                  spreadRadius: 0.3, // 기존 0.8 → 낮춤
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

    // 카드 스케일 토큰 (요청값 고정)
    final scale = 0.86;
    final cardPad = 12.0 * scale;
    final cardRadius = 12.0 * scale;
    final imgRadius = 8.0 * scale;
    final gapSm = 8.0 * scale;
    final gapLg = 12.0 * scale;
    final thumbW = 72.0 * scale;
    final thumbH = 72.0 * scale;
    final titleSize = 15.5 * scale;
    final contentSize = 13.0 * scale;

    // 디바이스 픽셀 비율 기반 이미지 다운샘플 크기
    int cw(double w) => (w * MediaQuery.of(context).devicePixelRatio).round();
    int ch(double h) => (h * MediaQuery.of(context).devicePixelRatio).round();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        centerTitle: true,
        title: const Text(
          "지원서 작성",
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
          ),
        ),
        // 구분선 조금 띄워서 표시
        flexibleSpace: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(height: 1, color: kDivider),
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Form(
            key: _formKey,
            autovalidateMode:
                AutovalidateMode.disabled, // 필요시 onUserInteraction로 변경 가능
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    "지원할 공고",
                    style: TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                ),

                // 카드
                Container(
                  padding: EdgeInsets.all(cardPad),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageData != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(imgRadius),
                          child: SizedBox(
                            width: thumbW,
                            height: thumbH,
                            child: (imageData is String && imageData.isNotEmpty)
                                ? Image.network(
                                    imageData,
                                    fit: BoxFit.cover,
                                    cacheWidth: cw(thumbW),
                                    cacheHeight: ch(thumbH),
                                  )
                                : (imageData is Uint8List)
                                ? Image.memory(
                                    imageData,
                                    fit: BoxFit.cover,
                                    cacheWidth: cw(thumbW),
                                    cacheHeight: ch(thumbH),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      if (imageData != null) SizedBox(width: gapLg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            SizedBox(height: gapSm),
                            Text(
                              content.isEmpty ? "내용이 없습니다." : content,
                              style: TextStyle(
                                fontSize: contentSize,
                                height: 1.45,
                                color: kTextPrimary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Divider(height: 1, thickness: 1, color: kDivider),
                const SizedBox(height: 24),

                const Text(
                  "질문",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // 질문 필드 (지연 렌더링)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.questions.length,
                  itemBuilder: (context, i) {
                    final q = widget.questions[i];
                    final node = _nodeFor(i);
                    final fieldKey = _formFieldKeyFor(i);
                    final hasError = fieldKey.currentState?.hasError ?? false;

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
                              fontWeight: FontWeight.w500,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _glowFieldWrapper(
                            isFocused: node.hasFocus,
                            hasError: hasError, // ✅ 에러면 글로우 끔
                            child: TextFormField(
                              key: fieldKey, // ✅ 에러 상태 확인용 키
                              focusNode: node,
                              minLines: 4,
                              maxLines: 8,
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextPrimary,
                              ),
                              decoration: _field(hint: "답변을 입력하세요...").copyWith(
                                hintStyle: const TextStyle(
                                  color: kTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                              initialValue: _answersData[i] ?? "",
                              onChanged: (v) => _answersData[i] = v,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "답변을 입력해 주세요."
                                  : null,
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
        ),
      ),

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
                color: Color(0xFF252525),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
