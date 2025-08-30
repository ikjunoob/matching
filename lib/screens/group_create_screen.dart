// group_create_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ask_for_common.dart' as theme;
import 'group_preview_screen.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final _nameCtrl = TextEditingController();
  final _introCtrl = TextEditingController();
  final _dateInfoCtrl = TextEditingController(text: "");
  final _placeInfoCtrl = TextEditingController(text: "");
  final _rulesCtrl = TextEditingController();
  final _planCtrl = TextEditingController();

  final _rulesFocus = FocusNode();

  // 카테고리
  final List<String> _categories = const ["스터디", "운동", "맛집탐방", "게임", "기타"];
  String _selectedCategory = "스터디";

  // 대표 이미지
  Uint8List? _imageBytes;
  File? _imageFile;

  // ===== 스타일 공통 =====
  static const _fieldRadius = 8.0;
  static const _fieldHPad = 12.0;
  static const _fieldVPad = 12.0;

  InputDecoration _fieldDeco(String hint) => const InputDecoration(
    hintStyle: TextStyle(color: theme.kTextMuted, fontSize: 15),
    filled: true,
    fillColor: theme.kWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_fieldRadius)),
      borderSide: BorderSide(color: theme.kDivider, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_fieldRadius)),
      borderSide: BorderSide(color: theme.kDivider, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_fieldRadius)),
      borderSide: BorderSide(color: theme.kAccent, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: _fieldHPad,
      vertical: _fieldVPad,
    ),
  ).copyWith(hintText: hint);

  // ===== 규칙 글머리 • 자동 처리 =====
  static const String _bullet = "• "; // 요구: 클릭 시 자동 생성, 엔터 시 자동 생성

  @override
  void initState() {
    super.initState();
    _rulesFocus.addListener(() {
      if (_rulesFocus.hasFocus && _rulesCtrl.text.trim().isEmpty) {
        _rulesCtrl.text = _bullet;
        _rulesCtrl.selection = TextSelection.collapsed(
          offset: _rulesCtrl.text.length,
        );
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _introCtrl.dispose();
    _dateInfoCtrl.dispose();
    _placeInfoCtrl.dispose();
    _rulesCtrl.dispose();
    _planCtrl.dispose();
    _rulesFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (res != null) {
        setState(() {
          _imageBytes = res.files.single.bytes;
          _imageFile = null;
        });
      }
      return;
    }

    // 모바일 권한
    PermissionStatus status = await Permission.photos.request();
    if (Platform.isAndroid && !status.isGranted) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("사진 권한이 필요합니다.")));
      }
      return;
    }

    final picked = await ImagePicker().pickImage(
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

  // 엔터(개행) 입력되면 자동으로 글머리 추가
  void _onRulesChanged(String v) {
    if (v.endsWith("\n")) {
      // 이미 글머리로 시작하면 중복 방지
      final next = "$v$_bullet";
      _rulesCtrl.text = next;
      _rulesCtrl.selection = TextSelection.collapsed(offset: next.length);
    }
    setState(() {});
  }

  List<String> _rulesLines() {
    return _rulesCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.replaceFirst(RegExp(r'^(•|ㆍ)\s*'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _buildGroup() {
    return {
      // 리스트 카드 공통 키
      "image": _imageBytes ?? _imageFile, // 카드에선 Uint8List/URL만 쓰면 됨
      "title": _nameCtrl.text.trim(),
      "category": _selectedCategory,
      "tags": const <String>[],
      "comments": 0,
      "views": 0,
      "likes": 0,
      "isLiked": false,
      "createdAt": DateTime.now(),

      // 상세(미리보기)용 확장 필드
      "intro": _introCtrl.text.trim(),
      "schedule": _dateInfoCtrl.text.trim(),
      "place": _placeInfoCtrl.text.trim(),
      "rules": _rulesLines(),
      "plan": _planCtrl.text.trim(),

      // 참여 인원(더미)
      "memberCount": 1,
      "memberLimit": 15,
    };
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label을(를) 입력해 주세요.";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.kPageBg,
      appBar: AppBar(
        backgroundColor: theme.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            size: 21,
            color: theme.kTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "모임 만들기",
          style: TextStyle(
            color: theme.kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: theme.kDivider),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final group = _buildGroup();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupPreviewScreen(group: group),
                ),
              );
            },
            child: const Text(
              "미리보기",
              style: TextStyle(
                color: theme.kAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) 대표 이미지
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorder(
                  dashPattern: const [6, 4],
                  color: theme.kDivider,
                  strokeWidth: 1.2,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(_fieldRadius),
                  child: Container(
                    height: 192,
                    decoration: BoxDecoration(
                      color: theme.kWhite,
                      borderRadius: BorderRadius.circular(_fieldRadius),
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
                            color: const Color(0xFFF8FAFC),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                  color: theme.kTextMuted,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "클릭하여 이미지 추가",
                                  style: TextStyle(color: theme.kTextMuted),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2) 모임 이름
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "모임 이름",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: _fieldDeco("모임 이름을 입력하세요"),
                validator: (v) => _required(v, "모임 이름"),
                style: const TextStyle(color: theme.kTextPrimary, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // 2) 카테고리
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "카테고리",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: theme.kTextPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.only(left: 0, right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_fieldRadius),
                      border: Border.all(color: theme.kDivider),
                      color: theme.kWhite,
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
                      borderRadius: BorderRadius.circular(_fieldRadius),
                      color: theme.kWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3) 한 줄 소개
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "한 줄 소개",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _introCtrl,
                decoration: _fieldDeco("모임을 한 문장으로 소개해주세요"),
                validator: (v) => _required(v, "한 줄 소개"),
                style: const TextStyle(color: theme.kTextPrimary, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // 4) 모임 정보 (달력/장소 아이콘 포함, 각 한 줄)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "모임 정보",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dateInfoCtrl,
                decoration: _fieldDeco("날짜 (예: 매주 화요일 저녁 7시)").copyWith(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 8),
                    child: Icon(
                      FontAwesomeIcons.calendarAlt,
                      size: 18,
                      color: theme.kTextPrimary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                validator: (v) => _required(v, "날짜"),
                style: const TextStyle(color: theme.kTextPrimary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placeInfoCtrl,
                decoration: _fieldDeco("장소 (예: 교내 스터디룸, 온라인 병행)").copyWith(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 8),
                    child: Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      size: 18,
                      color: theme.kTextPrimary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                validator: (v) => _required(v, "장소"),
                style: const TextStyle(color: theme.kTextPrimary, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // 5) 모임 규칙 (• 자동 생성)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "모임 규칙",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _rulesCtrl,
                focusNode: _rulesFocus,
                onChanged: _onRulesChanged,
                maxLines: 4,
                decoration: _fieldDeco("모임의 규칙을 자유롭게 작성해주세요."),
                style: const TextStyle(
                  color: theme.kTextPrimary,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // 6) 활동 계획
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  "활동 계획",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _planCtrl,
                maxLines: 6,
                decoration: _fieldDeco("모임의 구체적인 활동 계획을 작성해주세요."),
                style: const TextStyle(
                  color: theme.kTextPrimary,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("필수 항목을 확인해 주세요.")),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      _buildGroup(),
                    ); // 리스트에 삽입용 payload 반환
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_fieldRadius),
                    ),
                  ),
                  child: const Text(
                    "만들기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.kTextPrimary,
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
}
