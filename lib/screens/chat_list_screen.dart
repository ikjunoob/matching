import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRooms = [
      {'name': "함께 성장하는 독서 모임", 'lastMsg': "내일 6시 카페 어때요?", 'time': '1분 전'},
      {'name': "맛집탐방", 'lastMsg': "이번엔 어디갈까요?", 'time': '5분 전'},
      {'name': "조용한 카페 스터디", 'lastMsg': "오늘은 쉬어요!", 'time': '1시간 전'},
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
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "채팅",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: -0.2,
            ),
          ),
        ),
        titleSpacing: 0,
        toolbarHeight: 48, // NotificationScreen과 동일
      ),
      body: ListView.separated(
        itemCount: chatRooms.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.group)),
            title: Text(
              room['name']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              room['lastMsg']!,
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Text(
              room['time']!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
            onTap: () {
              // 추후 채팅방 이동 구현
            },
          );
        },
      ),
    );
  }
}
