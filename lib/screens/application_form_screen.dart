// application_form_screen.dart
import "package:flutter/material.dart";

const kAccent = Color(0xFF5BA7FF);
const kBorder = Color(0xFFE5E7EB);
const kTextPrimary = Color(0xFF111827);
const kTextMuted = Color(0xFF6B7280);

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

  @override
  void initState() {
    super.initState();
    _answers = List.generate(
      widget.questions.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _answers) c.dispose();
    super.dispose();
  }

  InputDecoration _field({String? hint}) => InputDecoration(
    hintText: hint ?? "답변을 입력하세요...",
    hintStyle: const TextStyle(color: kTextMuted),
    filled: true,
    fillColor: Colors.white,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: kBorder),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kBorder),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: kAccent, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final answers = <String>[];
    for (final c in _answers) answers.add(c.text.trim());

    // TODO: 서버/Firebase 업로드 등 처리
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("지원서가 제출되었습니다.")));
    Navigator.pop(context); // 폼 닫기
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.post["title"] as String?) ?? "제목 없음";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "지원서 작성",
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: kTextPrimary),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // 상단 요약 카드
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "지원할 공고",
                    style: TextStyle(fontSize: 12, color: kTextMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "질문",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),

            ...List.generate(widget.questions.length, (i) {
              final q = widget.questions[i];
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
                    TextFormField(
                      controller: _answers[i],
                      maxLines: 5,
                      decoration: _field(hint: "답변을 입력하세요..."),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "답변을 입력해 주세요."
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16 + 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "제출하기",
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
