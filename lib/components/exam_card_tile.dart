import 'package:edufy/pages/exam_details_page.dart';
import 'package:edufy/pages/exams.dart';
import 'package:flutter/material.dart';

class Exams extends StatefulWidget {
  const Exams({super.key});

  @override
  _ExamsState createState() => _ExamsState();
}

class _ExamsState extends State<Exams> {
  List<Map<String, dynamic>> exams = []; // Kart verilerini tutmak için liste

  void _addExamCard() {
    String examTitle = '';
    int correctAnswers = 0;
    int wrongAnswers = 0;
    int emptyAnswers = 0;

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController correctController = TextEditingController();
        final TextEditingController wrongController = TextEditingController();
        final TextEditingController emptyController = TextEditingController();

        return AlertDialog(
          title: const Text('Yeni Sınav Ekleyin'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sınav Başlığı',
                  ),
                ),
                TextField(
                  controller: correctController,
                  decoration: const InputDecoration(
                    labelText: 'Doğru Cevap Sayısı',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: wrongController,
                  decoration: const InputDecoration(
                    labelText: 'Yanlış Cevap Sayısı',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: emptyController,
                  decoration: const InputDecoration(
                    labelText: 'Boş Cevap Sayısı',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final correct = int.tryParse(correctController.text) ?? 0;
                final wrong = int.tryParse(wrongController.text) ?? 0;
                final empty = int.tryParse(emptyController.text) ?? 0;

                if (title.isNotEmpty) {
                  final newExam = {
                    'title': title,
                    'date': DateTime.now().toString(),
                    'correct': correct,
                    'wrong': wrong,
                    'empty': empty,
                  };

                  setState(() {
                    exams.add(newExam); // Kartı listeye ekle
                  });

                  titleController.clear();
                  correctController.clear();
                  wrongController.clear();
                  emptyController.clear(); // TextField'ları temizle
                }

                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _editExamCard(int index) {
    final TextEditingController _controller =
        TextEditingController(text: exams[index]['title']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sınav Başlığını Değiştirin'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Sınav Başlığı',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final title = _controller.text;

                if (title.isNotEmpty) {
                  setState(() {
                    exams[index]['title'] = title; // Başlığı güncelle
                  });
                }

                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('Değiştir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Deneme Sınavları",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(exams[index]['title']!), // Her kart için benzersiz anahtar
            background: Container(
              color: Colors.blue, // İsim değiştirme arka planı
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red, // Silme arka planı
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) {
              if (direction == DismissDirection.endToStart) {
                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Sınavı Sil'),
                      content: const Text(
                          'Bu sınavı silmek istediğinize emin misiniz?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Hayır'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              exams.removeAt(index); // Sınavı sil
                            });
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Evet'),
                        ),
                      ],
                    );
                  },
                );
              } else if (direction == DismissDirection.startToEnd) {
                _editExamCard(
                    index); // Sola kaydırıldığında düzenleme dialogunu aç
                return Future.value(
                    false); // İlgili işlemi gerçekleştirdikten sonra false döndür
              }
              return Future.value(false);
            },
            child: GestureDetector(
              onTap: () {
                // Kart tıklandığında detay sayfasına git
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamDetailsPage(
                      examTitle: exams[index]['title']!,
                      examDate: exams[index]['date']!,
                      correctAnswers: exams[index]['correct']!,
                      wrongAnswers: exams[index]['wrong']!,
                      emptyAnswers: exams[index]['empty']!,
                    ),
                  ),
                );
              },
              child: ExamCardTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExamDetailsPage(
                              examTitle: exams[index]['title']!,
                              examDate: exams[index]['date']!,
                              correctAnswers: exams[index]['correct']!,
                              wrongAnswers: exams[index]['wrong']!,
                              emptyAnswers: exams[index]['empty']!)));
                },
                examTileTitle: exams[index]['title']!,
                date: exams[index]['date']!,
              ),
            ),
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          // Sol alttaki büyük buton
          Padding(
            padding: const EdgeInsets.only(left: 50, bottom: 50),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.large(
                onPressed: () {}, // İlk buton için bir işlev belirleyin
                backgroundColor: Colors.grey[350],
                child: Image.asset(
                  'lib/images/gemini.png', // İkonun yolunu belirtiyoruz
                  width: 48, // Boyutu butona göre ayarlayabilirsiniz
                  height: 48,
                ),
              ),
            ),
          ),
          // Sağ alttaki ikinci buton
          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 50),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.large(
                onPressed: _addExamCard, // Artı butonuna basınca kart ekle
                backgroundColor: Colors.grey[350],
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
