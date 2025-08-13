import "dart:io";
import "dart:typed_data";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:file_picker/file_picker.dart";
import "package:permission_handler/permission_handler.dart";
import "package:intl/intl.dart";
import 'post_preview_screen.dart';

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

  DateTime? _deadline;
  File? _imageFile;
  Uint8List? _imageBytes;

  bool _templateInserted = false;
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
    final tags = _tagCtrl.text
        .trim()
        .split(" ")
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.startsWith("#") ? t.substring(1) : t)
        .where((t) => t.isNotEmpty)
        .toList();

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

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("모든 항목을 입력해 주세요")));
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
      final current = _contentCtrl.text;
      final idx = current.lastIndexOf(_templateText);
      if (idx != -1) {
        final next = (current.replaceRange(
          idx,
          idx + _templateText.length,
          "",
        )).trimRight();
        _contentCtrl
          ..text = next
          ..selection = TextSelection.collapsed(offset: next.length);
      }
    } else {
      final old = _contentCtrl.text.trimRight();
      final next = old.isEmpty ? _templateText : "$old\n$_templateText";
      _contentCtrl
        ..text = next
        ..selection = TextSelection.collapsed(offset: next.length);
    }
    setState(() => _templateInserted = !_templateInserted);
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

  // 필드 공통 데코
  InputDecoration _whiteFieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  // 한글 라인메트릭 고정용 텍스트 빌더
  Text _dropdownText(String s) => Text(
    s,
    strutStyle: const StrutStyle(
      height: 1.35,
      leading: 0,
      forceStrutHeight: true,
    ),
    style: const TextStyle(
      fontSize: 15,
      height: 1.35,
      textBaseline: TextBaseline.alphabetic,
      color: Colors.black87,
    ),
  );

  @override
  Widget build(BuildContext context) {
    const lightSky = Color(0xFF8EC9FF);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "구인구직 개설",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
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
              style: TextStyle(
                color: Color(0xFF5BA7FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이미지
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E8EB)),
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
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "클릭하여 이미지 추가",
                                style: TextStyle(color: Colors.grey),
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

              // 드롭다운(한글 잘림 방지: strutStyle + selectedItemBuilder)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                isDense: false,
                alignment: AlignmentDirectional.topStart,
                itemHeight: 48,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 320,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
                // 닫힌 상태의 기본 텍스트 스타일
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  textBaseline: TextBaseline.alphabetic,
                  color: Colors.black87,
                ),
                decoration: _whiteFieldDecoration(),
                // 닫힌 상태에서도 동일 라인메트릭 강제
                selectedItemBuilder: (context) => _categories
                    .map(
                      (e) => Align(
                        alignment: Alignment.centerLeft,
                        child: _dropdownText(e),
                      ),
                    )
                    .toList(),
                items: _categories
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: _dropdownText(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v ?? _selectedCategory),
              ),

              const SizedBox(height: 12),
              _sectionLabel("제목"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                decoration: _whiteFieldDecoration(hint: "게시물 제목을 입력하세요"),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  _sectionLabel("내용"),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: (_templateInserted
                          ? lightSky.withOpacity(0.18)
                          : const Color(0xFFEFF6FF)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _templateInserted
                            ? lightSky
                            : const Color(0xFFD9E6FF),
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
                      ),
                      child: Text(
                        _templateInserted ? "질문 템플릿 취소" : "질문 템플릿 추가",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 8,
                decoration: _whiteFieldDecoration(
                  hint: "상세 내용을 작성해주세요",
                ).copyWith(fillColor: Colors.white),
              ),

              const SizedBox(height: 12),
              _sectionLabel("태그"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tagCtrl,
                focusNode: _tagFocus,
                onChanged: _onTagChanged,
                decoration: _whiteFieldDecoration(hint: "#태그 입력"),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("모집 인원"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _headcountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _whiteFieldDecoration(hint: "예: 5"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          decoration: _whiteFieldDecoration(hint: "연도. 월. 일.")
                              .copyWith(
                                suffixIcon: IconButton(
                                  tooltip: "날짜 선택",
                                  icon: const Icon(
                                    Icons.calendar_month_rounded,
                                  ),
                                  onPressed: _pickDate,
                                ),
                              ),
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
    return "마감까지 ${h}시간 ${m}분";
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
}
