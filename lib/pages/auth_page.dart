import 'package:edufy/pages/home_page.dart';
import 'package:edufy/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user logged in
            if (snapshot.hasData) {
              return const HomePage();
            }
            // user not logged in
            else {
              return LoginPage();
            }
          }),
    );
  }
}
