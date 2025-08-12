import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 대표 이미지 추가
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // 카테고리
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: ['스터디', '운동', '맛집', '재능공유', '기타']
                  .map(
                    (label) =>
                        DropdownMenuItem(value: label, child: Text(label)),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            // 제목
            const TextField(
              decoration: InputDecoration(
                labelText: '제목',
                hintText: '게시물 제목을 입력하세요.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // 내용
            const TextField(
              maxLines: 8,
              decoration: InputDecoration(
                labelText: '내용',
                hintText: '구하는 목적, 필요한 내용, 기간 등을 상세하게 작성해주세요.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // 태그
            const TextField(
              decoration: InputDecoration(
                labelText: '태그',
                hintText: '#태그 입력 후 스페이스바',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 등록 버튼
            ElevatedButton(
              onPressed: () {
                // 게시글 등록 로직
                Navigator.pop(context); // 게시글 작성 후 이전 화면으로 돌아감
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('등록하기', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
