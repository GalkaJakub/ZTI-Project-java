import 'package:flutter/material.dart';
import 'package:wsp/features/home/home_shell.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          // TODO: login
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeShell()));
        },
        child: const Text('Kontynuuj z Google'),
      ),
    );
  }
}