// place_create_screen.dart
import "dart:io";
import "dart:typed_data";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:dropdown_button2/dropdown_button2.dart";
import "package:file_picker/file_picker.dart";
import "package:image_picker/image_picker.dart";
import "package:permission_handler/permission_handler.dart";
import 'package:dotted_border/dotted_border.dart';

/// ===== Design Tokens (post_screen과 동일) =====
const kAccent = Color(0xFF5BA7FF); // 포커스/포인트
const kBorder = Color(0xFFE5E7EB);
const kBorderStrong = Color(0xFFCBD5E1);
const kPageBg = Color(0xFFFFFFFF);
const kCardBg = Color(0xFFFFFFFF);
const kTextPrimary = Color(0xFF1F2937);
const kTextMuted = Color(0xFF6B7280);

/// 장소 CTA 버튼 색상(요청값)
const kPlaceCtaBg = Color(0xFFAED6F1);
const kPlaceCtaText = Color(0xFF1F2937);

/// 입력 규격
const kFieldRadius = 8.0;
const kFieldHPad = 12.0;
const kFieldVPad = 12.0;
const kFieldFont = 16.0;
const kLabelFont = 14.0;

/// 포스트 화면의 카메라 플레이스홀더와 동일한 배경
const kCameraTileBg = Color(0xFFF8FAFC);

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

/// ===== 장소 추천하기 =====
class PlaceCreateScreen extends StatefulWidget {
  const PlaceCreateScreen({super.key});

  @override
  State<PlaceCreateScreen> createState() => _PlaceCreateScreenState();
}

class _PlaceCreateScreenState extends State<PlaceCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  /// 장소 카테고리 (place_tab_screen과 동일 구성)
  final List<String> _categories = const [
    "전체",
    "카페",
    "스터디룸",
    "운동시설",
    "도서관",
    "공원",
    "라운지",
  ];
  String _selectedCategory = "카페";

  // 입력 컨트롤러
  final _nameCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // 이미지(최대 5장)
  final List<Uint8List> _images = [];

  bool _templateInserted = false;
  String? _contentBackup;

  static const String _templateText = """
이 장소의 매력은 무엇인가요?
-

어떤 사람에게 추천하나요?
-

가격대는 어떤가요?
-

나만의 꿀팁이 있다면?
-
""";

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ===== Validators =====
  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label은(는) 필수 입력란입니다.";
    return null;
  }

  // ===== 공통 데코레이션 =====
  InputDecoration _whiteFieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: kTextMuted,
        fontSize: kFieldFont * 0.95,
      ),
      filled: true,
      fillColor: MaterialStateColor.resolveWith(
        (_) => Colors.white,
      ), // ← 여기서 고정
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

  Text _dropdownText(String s) =>
      Text(s, style: const TextStyle(fontSize: 15, color: kTextPrimary));

  // ===== 템플릿 토글 =====
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
        ..selection = TextSelection.collapsed(offset: _templateText.length);
      setState(() => _templateInserted = true);
    }
  }

  // ===== 이미지 선택(최대 5장) =====
  Future<void> _pickImages() async {
    const maxCount = 5;
    int remain = maxCount - _images.length;
    if (remain <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("이미지는 최대 5장까지 등록할 수 있어요.")));
      return;
    }

    if (kIsWeb) {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (res != null) {
        final picked = res.files.where((f) => f.bytes != null).toList();
        for (final f in picked.take(remain)) {
          _images.add(f.bytes!);
        }
        setState(() {});
      }
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted && Platform.isAndroid) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("사진 권한이 필요합니다.")));
        return;
      }

      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked.isNotEmpty) {
        for (final x in picked.take(remain)) {
          final bytes = await x.readAsBytes();
          _images.add(bytes);
        }
        setState(() {});
      }
      return;
    }

    // 데스크톱
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (res != null) {
      final picked = res.files.where((f) => f.bytes != null).toList();
      for (final f in picked.take(remain)) {
        _images.add(f.bytes!);
      }
      setState(() {});
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ===== 제출 =====
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("필수 항목을 확인해 주세요.")));
      return;
    }

    final result = {
      "images": _images, // List<Uint8List>
      "name": _nameCtrl.text.trim(),
      "category": _selectedCategory,
      "content": _contentCtrl.text.trim(),
      // 위치/지도는 백엔드 연동 후 채울 예정 (지금은 placeholder)
      "location": null,
      "createdAt": DateTime.now(),
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            size: 21,
            color: kTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "장소 추천하기",
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kCardBg,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: kBorderStrong),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("미리보기는 추후 연결 예정입니다.")),
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
              // 1) 장소 이미지 (최대 5장) - 도트 보더 + 아이콘 뒤 배경 kCameraTileBg
              _sectionLabel("장소 이미지 (최대 5장)"),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < _images.length; i++)
                    _ImageTile(
                      bytes: _images[i],
                      onRemove: () => _removeImage(i),
                    ),
                  // 아이콘 아래 내부에 "0 / 5" 카운트 표시
                  _AddImageTile(
                    countText: "${_images.length} / 5",
                    onTap: _pickImages,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2) 장소 이름
              _sectionLabel("장소 이름"),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(
                        fontSize: kFieldFont,
                        color: kTextPrimary,
                      ),
                      decoration: _whiteFieldDecoration(
                        hint: "추천할 장소의 이름을 입력하세요",
                      ),
                      validator: (v) => _required(v, "장소 이름"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: Material(
                      color: const Color(0xFFF3F4F6), // 연한 배경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kFieldRadius),
                        side: const BorderSide(color: kBorder, width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(kFieldRadius),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("장소 이름으로 검색(더미)")),
                          );
                        },
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.search,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3) 위치 (지도 placeholder)
              _sectionLabel("위치"),
              const SizedBox(height: 6),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(kFieldRadius),
                  border: Border.all(color: kBorder),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "지도 표시 영역",
                  style: TextStyle(color: kTextMuted),
                ),
              ),

              const SizedBox(height: 16),

              // 4) 카테고리
              _sectionLabel("카테고리"),
              const SizedBox(height: 6),
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
                              state.didChange(value);
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 48,
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
                            offset: const Offset(0, -2),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                      if (state.hasError)
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0, top: 6.0),
                          child: Text(
                            "카테고리를 선택해 주세요.",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // 5) 내용 + 질문 템플릿 버튼
              Row(
                children: [
                  _sectionLabel("내용"),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: _templateInserted
                          ? kAccent.withOpacity(0.12)
                          : const Color.fromARGB(255, 244, 244, 244),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _templateInserted
                            ? kAccent
                            : const Color.fromARGB(255, 250, 250, 250),
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
                        foregroundColor: const Color.fromARGB(
                          255,
                          122,
                          129,
                          144,
                        ),
                      ),
                      child: Text(
                        _templateInserted ? "질문 템플릿 취소" : "질문 템플릿 추가",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
                decoration:
                    _whiteFieldDecoration(
                      hint: "장소에 대한 솔직한 리뷰를 남겨주세요. (예: 분위기, 가격, 꿀팁 등)",
                    ).copyWith(
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
                validator: (v) => _required(v, "내용"),
              ),

              const SizedBox(height: 22),

              // 6) 하단 CTA
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: const Color.fromRGBO(59, 138, 246, 0.4),
                    backgroundColor: kPlaceCtaBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kFieldRadius),
                    ),
                  ),
                  child: const Text(
                    "등록하기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kPlaceCtaText,
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

/// ===== 이미지 타일(썸네일 + 삭제) =====
class _ImageTile extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;
  const _ImageTile({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // ⬇︎ X 버튼을 박스 "안쪽으로 살짝" 이동
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            padding: EdgeInsets.zero,
            // 탭 영역을 딱 떨어지게 (원형 24)
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            onPressed: onRemove,
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===== 추가(카메라) 타일 (도트 보더 더 촘촘 + 배경 kCameraTileBg + 아이콘 아래 카운트) =====
class _AddImageTile extends StatelessWidget {
  final String countText; // e.g. "0 / 5"
  final VoidCallback onTap;
  const _AddImageTile({required this.countText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: const [1, 1], // 촘촘한 점선
      strokeCap: StrokeCap.round, // 점처럼 보이게
      color: kBorderStrong,
      strokeWidth: 2.0,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Material(
          color: const Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 35,
                    color: kTextMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    countText, // "0 / 5", "1 / 5" ...
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
