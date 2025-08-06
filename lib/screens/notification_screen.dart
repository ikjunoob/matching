import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {'title': "'함께 성장하는 독서 모임' 가입이 승인되었어요.", 'time': '3분 전', 'unread': true},
      {
        'title': "새로운 '맛집탐방' 모임이 만들어졌어요. 확인해보세요!",
        'time': '10분 전',
        'unread': true,
      },
      {'title': "'주말엔 브런치!' 모임 지원이 완료되었어요.", 'time': '1시간 전', 'unread': false},
      {
        'title': "'별 보러 가는 언덕' 모임에 새로운 댓글이 달렸어요.",
        'time': '3시간 전',
        'unread': false,
      },
      {'title': "새로운 공지사항이 등록되었습니다.", 'time': '어제', 'unread': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("알림", style: TextStyle(color: Colors.black)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: item['unread'] ? Colors.white : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                item['title'],
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  item['time'],
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: item['unread']
                  ? const Icon(
                      Icons.fiber_manual_record,
                      size: 10,
                      color: Color(0xFF06B6D4),
                    )
                  : const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: item['unread']
                  ? Colors.white
                  : const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}
