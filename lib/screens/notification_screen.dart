import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

// ===== Color Tokens (알림페이지 색상표 1:1 매핑) =====
const kScreenBg = Color(0xFFF9FAFB); // 페이지 배경
const kItemBgUnread = Color(0xFFFFFFFF); // 항목 배경(읽지 않음)
const kItemBgRead = Color(0xFFF9FAFB); // 항목 배경(읽음)

const kTitleColor = Color(0xFF1F2937); // 제목(타이틀)
const kTimeColor = Color(0xFF9CA3AF); // 알림 시간
const kBottomIconColor = Color(0xFF9CA3AF); // 하단 아이콘
const kBackIconColor = Color(0xFF6B7280); // 뒤로가기 아이콘

const kNewDot = Color(0xFF06B6D4); // 새 알림 점
const kClose = Color(0xFFD1D5DB); // X 버튼 기본
const kCloseHover = Color(0xFF4B5563); // X 버튼 hover

class _NotificationScreenState extends State<NotificationScreen> {
  // 알림 더미 데이터
  List<Map<String, dynamic>> notifications = [
    {"title": "'함께 성장하는 독서 모임' 가입이 승인되었어요.", "time": "3분 전", "unread": true},
    {
      "title": "새로운 '맛집탐방' 모임이 만들어졌어요. 확인해보세요!",
      "time": "10분 전",
      "unread": true,
    },
    {"title": "'주말엔 브런치!' 모임 지원이 완료되었어요.", "time": "1시간 전", "unread": false},
    {
      "title": "'별 보러 가는 언덕' 모임에 새로운 댓글이 달렸어요.",
      "time": "3시간 전",
      "unread": false,
    },
    {"title": "새로운 공지사항이 등록되었습니다.", "time": "어제", "unread": false},
    {
      "title": "'캠퍼스 농구동아리'에서 새로운 공지가 도착했습니다.",
      "time": "3시간 전",
      "unread": false,
    },
    {"title": "오늘의 소모임 추천: '산책메이트'를 확인해보세요.", "time": "오늘", "unread": false},
    {"title": "주말 플리마켓 봉사 모집 마감 안내", "time": "오늘", "unread": false},
    {"title": "학식 메뉴가 업데이트되었습니다.", "time": "어제", "unread": false},
    {"title": "'프로그래밍 스터디' 단톡방 초대가 도착했습니다.", "time": "어제", "unread": false},
    {"title": "캠퍼스 투어 후기 이벤트에 참여해보세요!", "time": "2일 전", "unread": false},
    {"title": "운영진에게 문의하신 답변이 등록되었습니다.", "time": "2일 전", "unread": false},
    {"title": "개인 정보가 정상적으로 수정되었습니다.", "time": "3일 전", "unread": false},
    {"title": "'이달의 인기 유저'로 선정되셨습니다! 축하드려요.", "time": "3일 전", "unread": false},
  ];

  // 아이콘 종류(모양)만 분기. 색은 표대로 고정 회색(kBottomIconColor).
  IconData _iconForTitle(String title) {
    if (title.contains("승인") || title.contains("완료") || title.contains("수정")) {
      return FontAwesomeIcons.checkCircle;
    }
    if (title.contains("공지")) return FontAwesomeIcons.bullhorn;
    if (title.contains("댓글")) return FontAwesomeIcons.solidCommentDots;
    if (title.contains("초대")) return FontAwesomeIcons.solidCommentDots;
    if (title.contains("이벤트")) return FontAwesomeIcons.infoCircle;
    if (title.contains("추천")) return FontAwesomeIcons.infoCircle;
    if (title.contains("모임") || title.contains("동아리")) {
      return FontAwesomeIcons.users;
    }
    return FontAwesomeIcons.infoCircle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
          color: kBackIconColor, // ← 표 기준 적용
          onPressed: () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "알림",
            style: TextStyle(
              color: Color(0xFF111827), // 상단 타이틀은 진한 텍스트
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: -0.2,
            ),
          ),
        ),
        titleSpacing: 0,
        toolbarHeight: 48,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final title = item["title"] as String;
          final time = item["time"] as String;
          final bool unread = item["unread"] as bool;

          return Dismissible(
            key: ValueKey("$title$time"),
            direction: unread
                ? DismissDirection.none
                : DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 30),
              color: Colors.red.withOpacity(0.13),
              child: const FaIcon(
                FontAwesomeIcons.trash,
                color: Colors.red,
                size: 20,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (unread) {
                  setState(() {
                    notifications[index]["unread"] = false;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: unread ? kItemBgUnread : kItemBgRead, // 표 적용
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: kTitleColor, // 표 적용
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          _iconForTitle(title),
                          size: 14,
                          color: kBottomIconColor, // 표 기준 고정 회색
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: kTimeColor, // 표 적용
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: unread
                      ? const FaIcon(
                          FontAwesomeIcons.solidCircle,
                          size: 8,
                          color: kNewDot, // 표 적용
                        )
                      : _CloseHoverButton(
                          onPressed: () {
                            setState(() {
                              notifications.removeAt(index);
                            });
                          },
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: unread ? kItemBgUnread : kItemBgRead, // 표 적용
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// X 버튼 hover 색상 구현 (모바일은 기본색만 보임)
class _CloseHoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CloseHoverButton({required this.onPressed});

  @override
  State<_CloseHoverButton> createState() => _CloseHoverButtonState();
}

class _CloseHoverButtonState extends State<_CloseHoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: IconButton(
        tooltip: "알림 삭제",
        icon: FaIcon(
          FontAwesomeIcons.times,
          size: 14,
          color: _hover ? kCloseHover : kClose, // 표 적용 + hover
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
