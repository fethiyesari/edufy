import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edufy/components/exam_card_tile.dart';
import 'package:edufy/pages/exam_details_page.dart';
import 'package:edufy/pages/gemini_page.dart';

class Exams extends StatefulWidget {
  const Exams({super.key});

  @override
  _ExamsState createState() => _ExamsState();
}

class _ExamsState extends State<Exams> {
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    fetchExamsFromFirestore();
  }

  // Firebase’den sınavları çekme fonksiyonu (kullanıcıya göre)
  Future<void> fetchExamsFromFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('exams')
          .where('userId', isEqualTo: userId) // Kullanıcıya göre filtrele
          .get();
      setState(() {
        exams = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  // Firebase’e sınav ekleyen fonksiyon (UID ile)
  Future<void> addExamToFirestore(
      String title, int correct, int wrong, int empty) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('exams').add({
        'title': title,
        'date': DateTime.now().toString(),
        'correct': correct,
        'wrong': wrong,
        'empty': empty,
        'userId': userId, // Kullanıcı UID'sini ekle
      });
    }
  }

  // Firestore’da sınav verisini güncelleme fonksiyonu
  Future<void> editExamInFirestore(String docId, String newTitle) async {
    await FirebaseFirestore.instance.collection('exams').doc(docId).update({
      'title': newTitle,
    });
  }

  // Firestore’dan sınav silme fonksiyonu
  Future<void> deleteExamFromFirestore(String docId) async {
    await FirebaseFirestore.instance.collection('exams').doc(docId).delete();
  }

  void _addExamCard() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController correctController = TextEditingController();
    final TextEditingController wrongController = TextEditingController();
    final TextEditingController emptyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
              onPressed: () async {
                final title = titleController.text;
                final correct = int.tryParse(correctController.text) ?? 0;
                final wrong = int.tryParse(wrongController.text) ?? 0;
                final empty = int.tryParse(emptyController.text) ?? 0;

                if (title.isNotEmpty) {
                  await addExamToFirestore(title, correct, wrong, empty);
                  await fetchExamsFromFirestore(); // Yeni sınav eklendikten sonra veriyi güncelle
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
              onPressed: () async {
                final title = _controller.text;

                if (title.isNotEmpty) {
                  setState(() {
                    exams[index]['title'] = title; // Local listeyi güncelle
                  });

                  // Firebase Firestore'da da güncelle
                  await editExamInFirestore(exams[index]['docId'], title);
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

  void showGeminiChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GeminiChatPage()),
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
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                // Sağdan sola kaydırıldığında (silme işlemi)
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
                          onPressed: () async {
                            final docId = exams[index]['docId'];

                            // Firebase’den sınavı sil
                            await deleteExamFromFirestore(docId);

                            setState(() {
                              exams
                                  .removeAt(index); // Yerel listeyi de güncelle
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
                // Soldan sağa kaydırıldığında (düzenleme işlemi)
                _editExamCard(index);
                return Future.value(
                    false); // Düzenleme yapıldıktan sonra false döndür
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
                onPressed: () {
                  showGeminiChat(context);
                }, // İlk buton için bir işlev belirleyin
                backgroundColor: Colors.grey[100],
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
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
