import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});

  @override
  _GeminiChatPageState createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final Gemini gemini = Gemini.instance; // Gemini instance'ını tanımlıyoruz
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User"); // Kullanıcı
  ChatUser geminiUser =
      ChatUser(id: "1", firstName: "Gemini"); // Gemini kullanıcısı

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyzeExamData(); // Sayfa açıldığında Firebase'den veri çekiyoruz
  }

  // Adım 1: Firebase'den veriyi çekip özet oluşturma
  Future<void> _fetchAndAnalyzeExamData() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('exams')
        .where('userId', isEqualTo: userId)
        .get();

    // Sınav verilerini özetliyoruz
    String examSummary = "Sınav Verileri:\n";
    for (var doc in snapshot.docs) {
      var data = doc.data();
      examSummary +=
          "Başlık: ${data['title']}, Doğru: ${data['correct']}, Yanlış: ${data['wrong']}, Boş: ${data['empty']}\n";
    }

    // Bu özeti Gemini'ye gönderiyoruz
    _sendMessageToGemini(examSummary);
  }

  // Adım 2: Veriyi Gemini'ye gönderip analiz ettirme
  void _sendMessageToGemini(String messageText) {
    final ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      text: messageText,
      createdAt: DateTime.now(),
    );

    setState(() {
      messages = [chatMessage, ...messages];
    });

    gemini.streamGenerateContent(messageText).listen((event) {
      String response = event.content?.parts
              ?.fold("", (previous, current) => "$previous ${current.text}") ??
          "";

      ChatMessage message = ChatMessage(
        user: geminiUser,
        text: response,
        createdAt: DateTime.now(),
      );

      setState(() {
        messages = [message, ...messages];
      });
    });
  }

  // Kullanıcıdan gelen mesajları işleyen onSend işlevi
  void _handleUserMessage(ChatMessage message) {
    setState(() {
      messages = [message, ...messages];
    });

    // Kullanıcı mesajını yalnızca Gemini'ye gönderiyoruz
    gemini.streamGenerateContent(message.text).listen((event) {
      String response = event.content?.parts
              ?.fold("", (previous, current) => "$previous ${current.text}") ??
          "";

      ChatMessage replyMessage = ChatMessage(
        user: geminiUser,
        text: response,
        createdAt: DateTime.now(),
      );

      setState(() {
        messages = [replyMessage, ...messages];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Chat")),
      body: DashChat(
        inputOptions: InputOptions(),
        currentUser: currentUser,
        messages: messages,
        onSend: _handleUserMessage, // Gerekli onSend parametresi eklendi
      ),
    );
  }
}
