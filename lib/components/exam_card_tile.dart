import 'package:flutter/material.dart';

class ExamCardTile extends StatelessWidget {
  final String examTileTitle;
  final String date;
  final VoidCallback onTap;

  const ExamCardTile({
    Key? key,
    required this.examTileTitle,
    required this.date,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Kart tıklandığında çalışacak fonksiyon
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examTileTitle,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date, // Tarih bilgisini göster
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
