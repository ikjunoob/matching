import 'package:flutter/material.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Row(
          children: [
            Text(
              "CC",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
            ),
            SizedBox(width: 4),
            Text(
              "CAMPUS CONNECT",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: Text("홈 화면입니다")),
    );
  }
}
