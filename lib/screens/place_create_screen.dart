import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dotted_border/dotted_border.dart';

// 미리보기 화면 import
import 'place_preview_screen.dart';

// ===== 디자인 토큰 =====
const kAccent = Color(0xFF5BA7FF);
const kBorder = Color(0xFFE5E7EB);
const kBorderStrong = Color(0xFFCBD5E1);
const kPageBg = Color(0xFFFFFFFF);
const kCardBg = Color(0xFFFFFFFF);
const kTextPrimary = Color(0xFF1F2937);
const kTextMuted = Color(0xFF6B7280);

const kPlaceCtaBg = Color(0xFFAED6F1);
const kPlaceCtaText = Color(0xFF1F2937);

const kFieldRadius = 8.0;
const kFieldHPad = 12.0;
const kFieldVPad = 12.0;
const kFieldFont = 16.0;
const kLabelFont = 14.0;

const kCameraTileBg = Color(0xFFF8FAFC);

// ===== 템플릿 삭제 방지 포매터 =====
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

// ===== 장소 추천하기 =====
class PlaceCreateScreen extends StatefulWidget {
  const PlaceCreateScreen({super.key});

  @override
  State<PlaceCreateScreen> createState() => _PlaceCreateScreenState();
}

class _PlaceCreateScreenState extends State<PlaceCreateScreen> {
  final _formKey = GlobalKey<FormState>();

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

  final _nameCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // 각 필드의 상태(에러 텍스트 등)를 가져오기 위한 Key
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _contentFieldKey = GlobalKey<FormFieldState<String>>();

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

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label은(는) 필수 입력란입니다.";
    return null;
  }

  InputDecoration _whiteFieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: kTextMuted,
        fontSize: kFieldFont * 0.95,
      ),
      filled: true,
      fillColor: MaterialStateColor.resolveWith((_) => Colors.white),
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
      // 기본 에러 메시지 공간을 숨겨서, 우리가 만든 _inlineError 위젯만 보이게 함
      errorStyle: const TextStyle(fontSize: 0, height: 0),
    );
  }

  /// 에러 메시지를 필드 좌측 하단에 예쁘게 표시하는 위젯
  Widget _inlineError(GlobalKey<FormFieldState<String>> key) {
    final error = key.currentState?.errorText;
    return SizedBox(
      height: 18,
      child: AnimatedOpacity(
        opacity: error == null ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        child: Align(
          alignment: Alignment.centerLeft, // << 왼쪽 정렬
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 3.0),
            child: Text(
              error ?? "",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
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

  Text _dropdownText(String s) =>
      Text(s, style: const TextStyle(fontSize: 15, color: kTextPrimary));

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

  Future<void> _pickImages() async {
    const maxCount = 5;
    int remain = maxCount - _images.length;
    if (remain <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지는 최대 5장까지 등록할 수 있어요.")),
        );
      }
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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("사진 권한이 필요합니다.")));
        }
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

  void _openPreview() {
    final previewData = {
      "images": _images,
      "name": _nameCtrl.text,
      "category": _selectedCategory,
      "content": _contentCtrl.text,
      "templateUsed": _templateInserted,
      "views": 0,
      "likes": 0,
      "isLiked": false,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlacePreviewScreen(placeData: previewData),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

    final result = {
      "images": _images,
      "name": _nameCtrl.text.trim(),
      "category": _selectedCategory,
      "content": _contentCtrl.text.trim(),
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
            onPressed: _openPreview,
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
              _sectionLabel("장소 이미지 (최대 5장)"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < _images.length; i++)
                    _ImageTile(
                      bytes: _images[i],
                      onRemove: () => _removeImage(i),
                    ),
                  // ▼▼▼▼▼ [수정] 카메라 아이콘을 Padding으로 감싸 오른쪽으로 이동 ▼▼▼▼▼
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: _AddImageTile(
                      countText: "${_images.length} / 5",
                      onTap: _pickImages,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel("장소 이름"),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _nameFieldKey,
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
                          color: const Color(0xFFF3F4F6),
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
                  _inlineError(_nameFieldKey),
                ],
              ),
              const SizedBox(height: 8),
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
              _sectionLabel("카테고리"),
              const SizedBox(height: 6),
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
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 48,
                    padding: const EdgeInsets.only(left: 0, right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kFieldRadius),
                      border: Border.all(color: kBorder),
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
              const SizedBox(height: 16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    key: _contentFieldKey,
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
                  _inlineError(_contentFieldKey),
                ],
              ),
              const SizedBox(height: 16),
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
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            padding: EdgeInsets.zero,
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

class _AddImageTile extends StatelessWidget {
  final String countText;
  final VoidCallback onTap;
  const _AddImageTile({required this.countText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: const [4, 4],
      strokeCap: StrokeCap.round,
      color: kBorderStrong,
      strokeWidth: 1.5,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Material(
          color: kCameraTileBg,
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
                    size: 28,
                    color: kTextMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    countText,
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
