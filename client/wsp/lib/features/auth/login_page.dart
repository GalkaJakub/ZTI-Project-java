import 'package:flutter/material.dart';
import 'package:wsp/features/auth/widgets/login_header.dart';
import 'package:wsp/features/auth/widgets/login_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F9FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Spacer(flex: 2),
                LoginHeader(),
                Spacer(),
                LoginCard(),
                Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}