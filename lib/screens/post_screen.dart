// post_screen.dart
import "dart:io";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:file_picker/file_picker.dart";
import "package:permission_handler/permission_handler.dart";
import "package:intl/intl.dart";
import 'post_preview_screen.dart';
import 'question_builder_screen.dart';
// dropdown_button2 패키지를 import 합니다.
import 'package:dropdown_button2/dropdown_button2.dart';

/// ===== Design Tokens (표 기준) =====
const kAccent = Color(0xFF5BA7FF); // 포커스/포인트
const kBorder = Color(0xFFE5E7EB); // 테두리
const kPageBg = Color(0xFFF9FAFB); // 메인 배경
const kCardBg = Color(0xFFFFFFFF); // 카드/서브 배경
const kTextPrimary = Color(0xFF111827); // 본문 텍스트
const kTextMuted = Color(0xFF6B7280); // 보조 텍스트
const kScrim = Color.fromRGBO(0, 0, 0, 0.2); // 스크림블
const kDDayBg = Color.fromRGBO(0, 0, 0, 0.55); // D-Day pill 배경

/// 입력 스타일 규격(표)
const kFieldRadius = 8.0; // 입력창/버튼 둥글기
const kFieldHPad = 12.0; // 입력창 안쪽 가로 여백
const kFieldVPad = 12.0; // 입력창 안쪽 세로 여백
const kFieldFont = 16.0; // 입력 글자 크기
const kLabelFont = 14.0; // 라벨 글자 크기

/// ===== 템플릿 삭제 방지 포매터 =====
class TemplateGuardFormatter extends TextInputFormatter {
  final String template;
  const TemplateGuardFormatter(this.template);

  bool _containsTemplateAsSubsequence(String text, String pattern) {
    int i = 0;
    for (int j = 0; j < text.length && i < pattern.length; j++) {
      if (text.codeUnitAt(j) == pattern.codeUnitAt(i)) i++;
    }
    return i == pattern.length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_containsTemplateAsSubsequence(newValue.text, template)) {
      return newValue;
    }
    return oldValue;
  }
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = ["전체", "스터디", "재능공유", "물품대여", "운동메이트"];
  String _selectedCategory = "전체";

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _headcountCtrl = TextEditingController();
  final _tagFocus = FocusNode();

  // 에러 텍스트를 읽기 위한 키 (레이아웃 고정 표시용)
  final _headcountFieldKey = GlobalKey<FormFieldState<String>>();
  final _deadlineFieldKey = GlobalKey<FormFieldState<String>>();

  DateTime? _deadline;
  File? _imageFile;
  Uint8List? _imageBytes;

  bool _templateInserted = false;
  String? _contentBackup;

  static const String _templateText = """
모집 대상 (예: 프론트엔드 개발자 1명)
-

활동 내용 (예: 매주 토요일 사이드 프로젝트 진행)
-

필요 역량 (예: React, Figma 사용 가능자)
-

추가 정보 (예: 모집 방식, 회비, 지원 방법, 기타)
-

""";

  Map<String, dynamic> _buildPostMap() {
    final tags = _parseTags(_tagCtrl.text);
    return {
      'image': _imageBytes,
      'title': _titleCtrl.text.trim(),
      'tags': tags,
      'comments': 0,
      'views': 0,
      'likes': 0,
      'category': _selectedCategory,
      'isLiked': false,
      'createdAt': DateTime.now(),
      'deadlineAt': _deadline,
      'headcount': _headcountCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
    };
  }

  List<String> _parseTags(String raw) {
    return raw
        .trim()
        .split(" ")
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.startsWith("#") ? t.substring(1) : t)
        .where((t) => t.isNotEmpty)
        .toList();
  }

  String? _requiredValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label은(는) 필수 입력란입니다.";
    return null;
  }

  String? _tagsValidator(String? v) {
    final tags = _parseTags(v ?? "");
    if (tags.isEmpty) return "태그를 1개 이상 입력해 주세요.";
    return null;
  }

  String? _headcountValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "모집 인원을 입력해 주세요.";
    final n = int.tryParse(v.trim());
    if (n == null) return "숫자만 입력해 주세요.";
    if (n <= 0) return "모집 인원은 1명 이상이어야 합니다.";
    if (n > 9999) return "값이 너무 큽니다.";
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("필수 항목을 확인해 주세요.")));
      return;
    }
    final post = _buildPostMap();
    Navigator.pop(context, post);
  }

  @override
  void initState() {
    super.initState();
    _tagFocus.addListener(() {
      if (_tagFocus.hasFocus && _tagCtrl.text.trim().isEmpty) {
        _tagCtrl.text = "#";
        _tagCtrl.selection = TextSelection.collapsed(
          offset: _tagCtrl.text.length,
        );
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    _headcountCtrl.dispose();
    _tagFocus.dispose();
    super.dispose();
  }

  void _toggleTemplate() {
    if (_templateInserted) {
      final restored = _contentBackup ?? "";
      _contentCtrl
        ..text = restored
        ..selection = TextSelection.collapsed(offset: restored.length);
      _contentBackup = null;
      setState(() => _templateInserted = false);
    } else {
      _contentBackup = _contentCtrl.text;
      _contentCtrl
        ..text = _templateText
        ..selection = const TextSelection.collapsed(
          offset: _templateText.length,
        );
      setState(() => _templateInserted = true);
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (res != null && res.files.single.bytes != null) {
        setState(() {
          _imageBytes = res.files.single.bytes!;
          _imageFile = null;
        });
      }
      return;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );
      if (res != null) {
        final path = res.files.single.path;
        if (path != null) {
          setState(() {
            _imageFile = File(path);
            _imageBytes = null;
          });
        } else if (res.files.single.bytes != null) {
          setState(() {
            _imageBytes = res.files.single.bytes!;
            _imageFile = null;
          });
        }
      }
      return;
    }

    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이 플랫폼에서는 이미지 선택이 지원되지 않습니다.")),
      );
      return;
    }

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("사진 권한이 필요합니다.")));
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageBytes = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: "마감일 선택",
    );
    if (picked != null) {
      setState(
        () =>
            _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59),
      );
    }
  }

  void _onTagChanged(String v) {
    if (v.isNotEmpty && !v.startsWith("#")) {
      _tagCtrl.text = "#$v";
      _tagCtrl.selection = TextSelection.collapsed(
        offset: _tagCtrl.text.length,
      );
      return;
    }
    if (v.isNotEmpty && v.endsWith(" ")) {
      if (!v.endsWith(" #")) {
        _tagCtrl.text = "$v#";
        _tagCtrl.selection = TextSelection.collapsed(
          offset: _tagCtrl.text.length,
        );
      }
    }
    setState(() {});
  }

  InputDecoration _whiteFieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: kTextMuted,
        fontSize: kFieldFont * 0.95,
      ),
      filled: true,
      fillColor: kCardBg,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: kBorder, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(kFieldRadius)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kBorder, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(kFieldRadius)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kAccent, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(kFieldRadius)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(kFieldRadius)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(kFieldRadius)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kFieldHPad,
        vertical: kFieldVPad,
      ),
    );
  }

  // 고정 위치 에러 표시(레이아웃 흔들림 방지)
  Widget _inlineError(GlobalKey<FormFieldState<String>> key) {
    final error = key.currentState?.errorText;
    return SizedBox(
      height: 18, // 고정 높이(두 필드 모두 동일하게 확보)
      child: AnimatedOpacity(
        opacity: error == null ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            error ?? "",
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: kLabelFont,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
        ),
      ),
    );
  }

  Text _dropdownText(String s) => Text(
    s,
    // strutStyle을 제거하거나 height 속성을 제거해야
    // dropdown_button2가 정상적으로 동작합니다.
    style: const TextStyle(
      fontSize: 15,
      color: kTextPrimary,
      // height: 1.35, // 이 속성이 있으면 메뉴 높이 계산에 오류가 생길 수 있음
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "구해요 등록",
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kCardBg,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          TextButton(
            onPressed: () {
              final post = _buildPostMap();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostPreviewScreen(post: post),
                ),
              );
            },
            child: const Text(
              "미리보기",
              style: TextStyle(color: kAccent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 대표 이미지
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 192,
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(kFieldRadius),
                    border: Border.all(color: kBorder, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageBytes != null)
                        Image.memory(_imageBytes!, fit: BoxFit.cover)
                      else if (_imageFile != null)
                        Image.file(_imageFile!, fit: BoxFit.cover)
                      else
                        Container(
                          color: const Color(0xFFF2F4F7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 36,
                                color: kTextMuted,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "클릭하여 이미지 추가",
                                style: TextStyle(color: kTextMuted),
                              ),
                            ],
                          ),
                        ),
                      if (_deadline != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: _pill(_formatRemain(_deadline!)),
                        ),
                      if (_headcountCtrl.text.trim().isNotEmpty)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _pill("${_headcountCtrl.text.trim()}명 모집"),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _sectionLabel("카테고리"),
              const SizedBox(height: 6),

              // ▼▼▼▼▼ 기존 DropdownButtonFormField를 아래 코드로 교체 ▼▼▼▼▼
              FormField<String>(
                initialValue: _selectedCategory,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "카테고리를 선택해 주세요.";
                  }
                  return null;
                },
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: _categories
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: _dropdownText(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                              state.didChange(value); // FormField에 변경 알림
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 48, // 버튼 높이를 다른 필드와 유사하게 설정
                            padding: const EdgeInsets.only(left: 0, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kFieldRadius),
                              border: Border.all(
                                color: state.hasError ? Colors.red : kBorder,
                              ),
                              color: kCardBg,
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black54,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kFieldRadius),
                              color: kCardBg,
                            ),
                            // 드롭다운 메뉴 위치 조정
                            offset: const Offset(0, -2),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                      // 유효성 검사 에러 메시지 표시
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 6.0),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // ▲▲▲▲▲ 여기까지 교체 ▲▲▲▲▲
              const SizedBox(height: 12),
              _sectionLabel("제목"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(
                  fontSize: kFieldFont,
                  color: kTextPrimary,
                ),
                decoration: _whiteFieldDecoration(hint: "게시물 제목을 입력하세요"),
                validator: (v) => _requiredValidator(v, "제목"),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  _sectionLabel("내용"),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: _templateInserted
                          ? kAccent.withOpacity(0.14)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _templateInserted
                            ? kAccent
                            : const Color(0xFFD9E6FF),
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: _toggleTemplate,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        foregroundColor: kTextPrimary,
                      ),
                      child: Text(
                        _templateInserted ? "질문 템플릿 취소" : "질문 템플릿 추가",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 7,
                style: const TextStyle(
                  fontSize: kFieldFont,
                  color: kTextPrimary,
                  height: 1.4,
                ),
                decoration: _whiteFieldDecoration(hint: "상세 내용을 작성해주세요")
                    .copyWith(
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(
                        kFieldHPad,
                        20,
                        kFieldHPad,
                        8,
                      ),
                    ),
                inputFormatters: _templateInserted
                    ? [TemplateGuardFormatter(_templateText)]
                    : const [],
                validator: (v) => _requiredValidator(v, "내용"),
              ),

              const SizedBox(height: 12),
              _sectionLabel("태그"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tagCtrl,
                focusNode: _tagFocus,
                onChanged: _onTagChanged,
                style: const TextStyle(
                  fontSize: kFieldFont,
                  color: kTextPrimary,
                ),
                decoration: _whiteFieldDecoration(hint: "#태그 입력"),
                validator: _tagsValidator,
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  // ===== 모집 인원 =====
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("모집 인원"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _headcountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: kFieldFont,
                            color: kTextPrimary,
                          ),
                          decoration: _whiteFieldDecoration(hint: "예: 5")
                              .copyWith(
                                // 레이아웃 흔들림 방지용 빈 helper (항상 자리만 차지)
                                helperText: " ",
                                helperStyle: const TextStyle(fontSize: 12),
                                // 기본 에러 스타일은 그대로 사용(빨간 글씨)
                              ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "모집 인원은 필수 입력란입니다.";
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null) return "숫자만 입력해 주세요.";
                            if (n <= 0) return "모집 인원은 1명 이상이어야 합니다.";
                            if (n > 9999) return "값이 너무 큽니다.";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ===== 마감일 =====
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("마감일"),
                        const SizedBox(height: 6),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _deadline == null
                                ? ""
                                : DateFormat(
                                    "yyyy. MM. dd.",
                                  ).format(_deadline!),
                          ),
                          onTap: _pickDate,
                          style: const TextStyle(
                            fontSize: kFieldFont,
                            color: kTextPrimary,
                          ),
                          decoration: _whiteFieldDecoration(hint: "연도. 월. 일.")
                              .copyWith(
                                suffixIcon: IconButton(
                                  tooltip: "날짜 선택",
                                  icon: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: kTextPrimary,
                                  ),
                                  onPressed: _pickDate,
                                ),
                                // 레이아웃 흔들림 방지용 빈 helper (항상 자리만 차지)
                                helperText: " ",
                                helperStyle: const TextStyle(fontSize: 12),
                              ),
                          validator: (_) =>
                              _deadline == null ? "마감일은 필수 입력란입니다." : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("필수 항목을 확인해 주세요.")),
                      );
                      return;
                    }

                    // 질문 작성 화면으로 이동
                    final questions = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuestionBuilderScreen(),
                      ),
                    );
                    if (questions == null) return;

                    // post + questions 합치기
                    final post = _buildPostMap();
                    post["questions"] = questions;

                    if (mounted)
                      Navigator.pop(context, post); // ← AskForScreen으로 post 반환
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: const Color.fromRGBO(59, 138, 246, 0.4),
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kFieldRadius),
                    ),
                  ),
                  child: const Text(
                    "다음",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
