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

  // Net hesaplayan fonksiyon
  double _calculateNetScore() {
    double deductedCorrectAnswers = wrongAnswers / 4;
    return correctAnswers - deductedCorrectAnswers;
  }

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
            const SizedBox(height: 20),
            // Net puanı gösteren yuvarlak köşeli dikdörtgen
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Net Puan',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _calculateNetScore().toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Ortasında küçük bir yuvarlak olan çizgi
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 2,
                    color: Colors.grey, // Çizgi rengi
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.grey, // Yuvarlağın rengi
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
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
