import 'package:flutter/material.dart';

class WorkSpaceScreen extends StatelessWidget {
  final String title;
  const WorkSpaceScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('워크스페이스 상세 (더미)')),
    );
  }
}
