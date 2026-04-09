import 'package:flutter/material.dart';
import 'package:wsp/features/auth/widgets/sign_in_button.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Zaloguj się',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Logowanie przez Google.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          const SignInButton(),
        ],
      ),
    );
  }
}