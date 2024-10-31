import 'package:edufy/components/my_card_tile.dart';
import 'package:edufy/pages/books.dart';
import 'package:edufy/pages/exams.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Edufy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            MyCardTile(
              tileTitle: "Kitaplar",
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Books()));
              },
            ),
            const SizedBox(
              height: 25,
            ),
            MyCardTile(
              tileTitle: "Deneme Sınavları",
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Exams()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
