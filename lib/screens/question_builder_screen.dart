import "package:flutter/material.dart";

class QuestionBuilderScreen extends StatefulWidget {
  const QuestionBuilderScreen({super.key});

  @override
  State<QuestionBuilderScreen> createState() => _QuestionBuilderScreenState();
}

class _QuestionBuilderScreenState extends State<QuestionBuilderScreen> {
  static const int _minCount = 3;
  static const int _maxCount = 10;

  static const List<String> _placeholders = [
    "간단한 자기소개를 부탁드려요.",
    "팀에 지원하게 된 동기가 무엇인가요?",
    "관련 경험이 있다면 알려주세요.",
    "자신을 어필할 수 있는 내용을 자유롭게 작성해주세요.",
    "포트폴리오나 참고 자료가 있다면 링크를 첨부해주세요.",
    "팀에 기여하고 싶은 점이 있다면 무엇인가요?",
    "어떤 성향의 팀원과 함께하고 싶으신가요?",
    "어려움을 해결했던 경험에 대해 이야기해주세요.",
    "이번 활동을 통해 무엇을 얻고 싶으신가요?",
    "마지막으로 하고 싶은 말이 있나요?",
  ];

  final List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _minCount; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (_controllers.length >= _maxCount) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeQuestion() {
    if (_controllers.length <= _minCount) return;
    setState(() {
      final last = _controllers.removeLast();
      last.dispose();
    });
  }

  bool get _canAdd => _controllers.length < _maxCount;
  bool get _canRemove => _controllers.length > _minCount;

  // 공통 인풋 데코 (텍스트 작게, placeholder 회색)
  InputDecoration _whiteFieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 14,
        height: 1.35,
      ),
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6E8EB)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6E8EB)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF5BA7FF)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black, // 질문 N 라벨 검정
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EB)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black54 : Colors.black26,
        ),
      ),
    );
  }

  void _submit() {
    final filled = _controllers.map((c) => c.text.trim()).toList();
    final first3Filled = filled.take(_minCount).every((t) => t.isNotEmpty);
    if (!first3Filled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("최소 3개의 질문을 입력해 주세요.")));
      return;
    }
    Navigator.pop(context, filled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "지원서 질문 생성",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 6.0, bottom: 10),
                  child: Text(
                    "지원자에게 궁금한 질문을 폼으로 만들어보세요. 최소 3개, 최대 10개까지 추가할 수 있습니다.",
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ),
                ...List.generate(_controllers.length, (index) {
                  final number = index + 1;
                  final hint = _placeholders[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _controllers.length - 1 ? 10 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("질문 $number"),
                        TextFormField(
                          controller: _controllers[index],
                          style: const TextStyle(
                            // 입력 텍스트
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.black87,
                          ),
                          decoration: _whiteFieldDecoration(hint: hint),
                        ),
                        if (index == _controllers.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_controllers.length == _minCount)
                                  _circleIconButton(
                                    icon: Icons.add,
                                    onTap: _addQuestion,
                                    enabled: _canAdd,
                                  )
                                else if (_controllers.length == _maxCount)
                                  _circleIconButton(
                                    icon: Icons.remove,
                                    onTap: _removeQuestion,
                                    enabled: _canRemove,
                                  )
                                else
                                  Row(
                                    children: [
                                      _circleIconButton(
                                        icon: Icons.add,
                                        onTap: _addQuestion,
                                        enabled: _canAdd,
                                      ),
                                      const SizedBox(width: 12),
                                      _circleIconButton(
                                        icon: Icons.remove,
                                        onTap: _removeQuestion,
                                        enabled: _canRemove,
                                      ),
                                    ],
                                  ),
                              ],
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

      // 하단 버튼 - 화면 너비 꽉 채우기
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16 + 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E8EB), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity, // ★ 추가: 가로 꽉 채우기
          height: 54,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BA7FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "등록하기",
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
