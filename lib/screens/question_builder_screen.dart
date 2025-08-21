import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final List<bool> _hintOn = []; // ▷ 각 필드의 hint 표시 여부
  final _formKey = GlobalKey<FormState>();

  TextEditingController _newController({
    String? initial,
    required bool showHint,
  }) {
    final c = TextEditingController(text: initial ?? "");
    c.addListener(() {
      if (mounted) setState(() {}); // x 아이콘 갱신
    });
    _hintOn.add(showHint);
    return c;
  }

  @override
  void initState() {
    super.initState();
    // 초기 3개는 "실제 텍스트 값"으로 채워둠. (힌트는 표시할 필요 없음)
    for (int i = 0; i < _minCount; i++) {
      _controllers.add(
        _newController(initial: _placeholders[i], showHint: false),
      );
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
    final idx = _controllers.length;
    final seed = idx < _placeholders.length ? _placeholders[idx] : "";
    // 새로 추가된 칸은 플레이스홀더를 "실제 텍스트"로 미리 넣고 싶으면 showHint:false + initial:seed
    // 빈 칸으로 추가하고 싶으면: initial:null, showHint:true
    _controllers.add(_newController(initial: seed, showHint: false));
    setState(() {});
  }

  void _removeQuestion() {
    if (_controllers.length <= _minCount) return;
    setState(() {
      final last = _controllers.removeLast();
      last.dispose();
      _hintOn.removeLast();
    });
  }

  bool get _canAdd => _controllers.length < _maxCount;
  bool get _canRemove => _controllers.length > _minCount;

  InputDecoration _whiteFieldDecoration({
    required TextEditingController controller,
    required bool showHint,
    String? hint,
  }) {
    return InputDecoration(
      hintText: showHint
          ? (hint ?? "")
          : null, // ▷ x 누르면 showHint=false 로 바뀌어 빈칸 유지
      hintStyle: const TextStyle(
        color: Color(0xFF111827),
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

      // ▷ 'x' : 크기 줄이고, 탭 영역은 유지
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () {
                controller.clear(); // 텍스트 삭제
                final i = _controllers.indexOf(controller);
                if (i != -1) _hintOn[i] = false; // ▷ 힌트도 비활성화 → 완전 빈 박스
                setState(() {});
              },
              tooltip: "지우기",
            )
          : null,

      // (선택) suffixIcon 위치 미세조정이 필요하면 suffixIconConstraints로 조절 가능
      // suffixIconConstraints: const BoxConstraints.tightFor(height: 40, width: 40),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
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
          size: 18, // 살짝 더 작게
          color: enabled ? Colors.black54 : Colors.black26,
        ),
      ),
    );

    // ▼ 만약 FontAwesome의 plusCircle / minusCircle을 쓰고 싶다면
    //    위 컨테이너의 원·테두리를 제거해야 "겹침"이 안 보임:
    // return IconButton(icon: FaIcon(FontAwesomeIcons.plusCircle), onPressed: onTap);
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
            FontAwesomeIcons.arrowLeft,
            color: Colors.black,
            size: 21,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "지원서 질문 생성",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // ← 그림자 제거
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFCBD5E1), // kBorderStrong 과 동일
          ),
        ),
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
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF1F2937)),
                  ),
                ),
                ...List.generate(_controllers.length, (index) {
                  final number = index + 1;
                  final hint = (index < _placeholders.length)
                      ? _placeholders[index]
                      : null;

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
                            fontSize: 14,
                            height: 1.35,
                            color: Color(0xFF1F2937),
                          ),
                          decoration: _whiteFieldDecoration(
                            controller: _controllers[index],
                            showHint: _hintOn[index],
                            hint: hint,
                          ),
                        ),
                        if (index == _controllers.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_controllers.length == _minCount)
                                  _circleIconButton(
                                    icon: FontAwesomeIcons.plus, // ← 원 없는 아이콘
                                    onTap: _addQuestion,
                                    enabled: _canAdd,
                                  )
                                else if (_controllers.length == _maxCount)
                                  _circleIconButton(
                                    icon: FontAwesomeIcons.minus, // ← 원 없는 아이콘
                                    onTap: _removeQuestion,
                                    enabled: _canRemove,
                                  )
                                else
                                  Row(
                                    children: [
                                      _circleIconButton(
                                        icon: FontAwesomeIcons.plus,
                                        onTap: _addQuestion,
                                        enabled: _canAdd,
                                      ),
                                      const SizedBox(width: 12),
                                      _circleIconButton(
                                        icon: FontAwesomeIcons.minus,
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
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E8EB), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
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
