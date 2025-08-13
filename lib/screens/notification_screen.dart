import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

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

  // 제목 키워드로 아이콘/색 결정
  IconData _iconForTitle(String title) {
    if (title.contains("승인") || title.contains("완료") || title.contains("수정")) {
      return Icons.check_circle;
    }
    if (title.contains("공지")) return Icons.campaign;
    if (title.contains("댓글")) return Icons.mode_comment;
    if (title.contains("초대")) return Icons.mail_outline;
    if (title.contains("이벤트")) return Icons.card_giftcard;
    if (title.contains("추천")) return Icons.thumb_up_alt_outlined;
    if (title.contains("모임") || title.contains("동아리")) {
      return Icons.groups_2_outlined;
    }
    return Icons.notifications_none;
  }

  Color _iconColorForTitle(String title) {
    if (title.contains("승인") || title.contains("완료")) {
      return const Color(0xFF10B981); // 초록
    }
    if (title.contains("공지")) return const Color(0xFFF59E0B); // 주황
    if (title.contains("댓글")) return const Color(0xFF3B82F6); // 파랑
    if (title.contains("초대")) return const Color(0xFF8B5CF6); // 보라
    if (title.contains("이벤트")) return const Color(0xFFEF4444); // 빨강
    if (title.contains("추천")) return const Color(0xFF06B6D4); // 시그니처
    return const Color(0xFF9CA3AF); // 기본 회색
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "알림",
            style: TextStyle(
              color: Colors.black,
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
              child: const Icon(Icons.delete, color: Colors.red, size: 26),
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
                  color: unread ? Colors.white : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  // ⬇️ 시간 텍스트 왼쪽에 아이콘 + 일정 간격
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForTitle(title),
                          size: 14,
                          color: _iconColorForTitle(title),
                        ),
                        const SizedBox(width: 6), // 아이콘-시간 간격 고정
                        Text(
                          time,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: unread
                      ? const Icon(
                          Icons.fiber_manual_record,
                          size: 10,
                          color: Color(0xFF06B6D4),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          tooltip: "알림 삭제",
                          onPressed: () {
                            setState(() {
                              notifications.removeAt(index);
                            });
                          },
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: unread ? Colors.white : const Color(0xFFF9FAFB),
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
