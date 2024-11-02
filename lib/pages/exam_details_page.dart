import 'package:flutter/material.dart';

class ExamDetailsPage extends StatelessWidget {
  final String examTitle;
  final String examDate;
  final int correctAnswers; // Doğru cevap sayısı
  final int wrongAnswers; // Yanlış cevap sayısı
  final int emptyAnswers; // Boş cevap sayısı

  const ExamDetailsPage({
    super.key,
    required this.examTitle,
    required this.examDate,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(examTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sınav Başlığı: $examTitle',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Sınav Tarihi: $examDate',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            // Yuvarlak şekiller için Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularIndicator('Doğru', correctAnswers, Colors.green),
                _buildCircularIndicator('Yanlış', wrongAnswers, Colors.red),
                _buildCircularIndicator('Boş', emptyAnswers, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Yuvarlak şekil oluşturan yardımcı fonksiyon
  Widget _buildCircularIndicator(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}
