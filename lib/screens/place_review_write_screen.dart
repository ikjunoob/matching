import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class theme {
  static const kTextPrimary = Color(0xFF1F2937);
  static const kTextMuted = Color(0xFF6B7280);
  static const kDivider = Color(0xFFE5E7EB);
  static const kAccent = Color(0xFF5BA7FF);
  static const kCardBg = Colors.white;
}

class PlaceReviewWriteScreen extends StatefulWidget {
  final String placeTitle;

  const PlaceReviewWriteScreen({super.key, required this.placeTitle});

  @override
  State<PlaceReviewWriteScreen> createState() => _PlaceReviewWriteScreenState();
}

class _PlaceReviewWriteScreenState extends State<PlaceReviewWriteScreen> {
  int _rating = 0;
  late int _year;
  int _month = DateTime.now().month;
  int _day = DateTime.now().day;
  final _contentCtrl = TextEditingController();

  // ===== 폭 튜닝용 파라미터 =====
  static const double kGap = 10.0; // 드롭다운 사이 간격
  static const EdgeInsets kBtnHPad = EdgeInsets.symmetric(
    horizontal: 8,
  ); // 버튼 좌우 패딩
  static const double kIconApproxWidth = 24; // ▼ 아이콘 영역(대략)
  static const double kBtnHeight = 48;

  // 최소/최대 폭 (원하는 대로 조정)
  static const double kYearMin = 120, kYearMax = 200;
  static const double kMonthMin = 100, kMonthMax = 110;
  static const double kDayMin = 115, kDayMax = 170;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(15, (i) => now - i); // 최근 15년
  }

  List<int> get _months => List<int>.generate(12, (i) => i + 1);

  List<int> get _days {
    final lastDay = DateTime(_year, _month + 1, 0).day;
    return List<int>.generate(lastDay, (i) => i + 1);
  }

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  // ===== DropdownButton2 공통 스타일 =====
  ButtonStyleData _btnStyle(bool error) => ButtonStyleData(
    height: kBtnHeight,
    padding: kBtnHPad,
    decoration: BoxDecoration(
      color: theme.kCardBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: error ? Colors.red : theme.kDivider),
    ),
  );

  // 폭을 직접 주는 스타일(copyWith 없이 새로 생성)
  ButtonStyleData _btnStyleW(double w, {bool error = false}) => ButtonStyleData(
    width: w,
    height: kBtnHeight,
    padding: kBtnHPad,
    decoration: BoxDecoration(
      color: theme.kCardBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: error ? Colors.red : theme.kDivider),
    ),
  );

  IconStyleData get _iconStyle => const IconStyleData(
    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
  );

  DropdownStyleData get _ddStyle => DropdownStyleData(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: theme.kCardBg,
    ),
    offset: const Offset(0, -2),
  );

  MenuItemStyleData get _menuItemStyle => const MenuItemStyleData(
    height: 40,
    padding: EdgeInsets.symmetric(horizontal: 14),
  );

  // ===== 텍스트 측정 & 폭 계산 =====
  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    return tp.width;
  }

  /// 라벨 글꼴(+패딩, 아이콘)을 고려한 "원하는 폭"
  double _desiredWidth(
    String label,
    TextStyle style, {
    required double minW,
    required double maxW,
  }) {
    final textW = _measureTextWidth(label, style);
    final padW = kBtnHPad.horizontal; // 좌우 패딩 합
    final want = textW + padW + kIconApproxWidth;
    return want.clamp(minW, maxW);
  }

  /// 세 값의 합이 가용폭을 초과하면 비율로 축소(min 보장). 반환: [yearW, monthW, dayW]
  List<double> _fitToAvailable({
    required double available,
    required double yearW,
    required double monthW,
    required double dayW,
    required List<double> mins,
  }) {
    double y = yearW, m = monthW, d = dayW;
    final gaps = kGap * 2;
    double sum = y + m + d + gaps;

    if (sum <= available) return [y, m, d];

    // 1차 비율 축소
    final scale = (available - gaps) / (y + m + d);
    y = (y * scale).clamp(mins[0], double.infinity);
    m = (m * scale).clamp(mins[1], double.infinity);
    d = (d * scale).clamp(mins[2], double.infinity);

    // 여전히 넘치면(최소폭 때문에) 초과분을 균등 분배로 더 줄임
    sum = y + m + d + gaps;
    if (sum > available) {
      double need = sum - available;

      double reduceSlot(double current, double min, double take) {
        final room = current - min;
        if (room <= 0) return current;
        final use = room >= take ? take : room;
        return current - use;
      }

      // 라운드-로빈으로 최대 3라운드
      for (int round = 0; round < 3 && need > 0.01; round++) {
        final share = need / 3.0;
        final beforeNeed = need;

        final ny = reduceSlot(y, mins[0], share);
        need -= (y - ny);
        y = ny;

        final nm = reduceSlot(m, mins[1], share);
        need -= (m - nm);
        m = nm;

        final nd = reduceSlot(d, mins[2], share);
        need -= (d - nd);
        d = nd;

        if ((beforeNeed - need) < 0.01) break; // 더 줄일 여지가 없음
      }
    }
    return [y, m, d];
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("별점을 선택해 주세요.")));
      return;
    }
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("리뷰 내용을 입력해 주세요.")));
      return;
    }

    final date = DateTime(_year, _month, _day);
    Navigator.pop<Map<String, dynamic>>(context, {
      "author": "익명",
      "rating": _rating,
      "content": _contentCtrl.text.trim(),
      "createdAt": date, // 방문 날짜를 표시용으로 사용
    });
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: theme.kTextPrimary, fontSize: 15);

    return Scaffold(
      backgroundColor: theme.kCardBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: theme.kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "리뷰 작성",
          style: TextStyle(
            color: theme.kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: theme.kDivider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 문구 + 별점
            const Center(
              child: Text(
                "이 장소는 어떠셨나요?",
                style: TextStyle(
                  color: theme.kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  splashRadius: 20,
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: FaIcon(
                    i < _rating
                        ? FontAwesomeIcons.solidStar
                        : FontAwesomeIcons.star,
                    color: const Color(0xFFFFB300),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: theme.kDivider, height: 1),
            const SizedBox(height: 16),

            // 방문 날짜
            const Text(
              "방문 날짜",
              style: TextStyle(
                color: theme.kTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // === 폭 자동 계산: LayoutBuilder로 가용폭→각 드롭다운 폭 할당 ===
            LayoutBuilder(
              builder: (context, constraints) {
                final available = constraints.maxWidth;

                // "내용에 맞는" 희망 폭(최대치 기준으로 계산)
                final yearLabel = "${_year}년";
                final monthLabel = "${_month}월";
                final dayLabel = "${_day}일";

                double wantYear = _desiredWidth(
                  yearLabel,
                  labelStyle,
                  minW: kYearMin,
                  maxW: kYearMax,
                );
                double wantMonth = _desiredWidth(
                  monthLabel,
                  labelStyle,
                  minW: kMonthMin,
                  maxW: kMonthMax,
                );
                double wantDay = _desiredWidth(
                  dayLabel,
                  labelStyle,
                  minW: kDayMin,
                  maxW: kDayMax,
                );

                // 가용폭 초과 시 비율 축소 (최소폭 보장)
                final widths = _fitToAvailable(
                  available: available,
                  yearW: wantYear,
                  monthW: wantMonth,
                  dayW: wantDay,
                  mins: const [kYearMin, kMonthMin, kDayMin],
                );

                final yearW = widths[0];
                final monthW = widths[1];
                final dayW = widths[2];

                return Row(
                  children: [
                    SizedBox(
                      width: yearW,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<int>(
                          isExpanded: true,
                          value: _year,
                          items: _years
                              .map(
                                (y) => DropdownMenuItem<int>(
                                  value: y,
                                  child: Text("$y년", style: labelStyle),
                                ),
                              )
                              .toList(),
                          // 선택 표시 한 줄 고정
                          selectedItemBuilder: (_) => _years
                              .map(
                                (y) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$y년",
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: labelStyle,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _year = v!;
                            final last = DateTime(_year, _month + 1, 0).day;
                            if (_day > last) _day = last;
                          }),
                          buttonStyleData: _btnStyleW(yearW),
                          iconStyleData: _iconStyle,
                          dropdownStyleData: _ddStyle,
                          menuItemStyleData: _menuItemStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: kGap),
                    SizedBox(
                      width: monthW,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<int>(
                          isExpanded: true,
                          value: _month,
                          items: _months
                              .map(
                                (m) => DropdownMenuItem<int>(
                                  value: m,
                                  child: Text("$m월", style: labelStyle),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (_) => _months
                              .map(
                                (m) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$m월",
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: labelStyle,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _month = v!;
                            final last = DateTime(_year, _month + 1, 0).day;
                            if (_day > last) _day = last;
                          }),
                          buttonStyleData: _btnStyleW(monthW),
                          iconStyleData: _iconStyle,
                          dropdownStyleData: _ddStyle,
                          menuItemStyleData: _menuItemStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: kGap),
                    SizedBox(
                      width: dayW,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<int>(
                          isExpanded: true,
                          value: _day,
                          items: _days
                              .map(
                                (d) => DropdownMenuItem<int>(
                                  value: d,
                                  child: Text("$d일", style: labelStyle),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (_) => _days
                              .map(
                                (d) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$d일",
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: labelStyle,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _day = v!),
                          buttonStyleData: _btnStyleW(dayW),
                          iconStyleData: _iconStyle,
                          dropdownStyleData: _ddStyle,
                          menuItemStyleData: _menuItemStyle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            const Text(
              "리뷰 내용",
              style: TextStyle(
                color: theme.kTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "장소에 대한 솔직한 경험을 공유해 주세요.",
                hintStyle: const TextStyle(
                  color: theme.kTextMuted,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: theme.kDivider),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: theme.kDivider),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: theme.kAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "등록하기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
