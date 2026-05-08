import 'package:flutter/material.dart';
import 'package:wsp/features/auth/services/auth_service.dart';
import 'package:wsp/features/auth/widgets/sign_in_button.dart';
import 'package:wsp/features/home/home_shell.dart';

enum _AuthMode { signIn, register }

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  _AuthMode _mode = _AuthMode.signIn;
  bool _loading = false;
  bool _obscurePassword = true;

  bool get _isRegisterMode => _mode == _AuthMode.register;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final response = _isRegisterMode
          ? await _authService.register(
              displayName: _displayNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await _authService.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            );

      if (!mounted) return;
      debugPrint('Logged in as ${response.user.email}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (e) {
      if (!mounted) return;

      final action = _isRegisterMode ? 'rejestracji' : 'logowania';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd $action: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _isRegisterMode ? _AuthMode.signIn : _AuthMode.register;
      _formKey.currentState?.reset();
      _confirmPasswordController.clear();
    });
  }

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
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isRegisterMode ? 'Utwórz konto' : 'Zaloguj się',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _isRegisterMode
                    ? 'Załóż konto, żeby dołączyć do wspólnego planowania.'
                    : 'Wpisz dane konta utworzonego w aplikacji.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (_isRegisterMode) ...[
                TextFormField(
                  controller: _displayNameController,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa użytkownika',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final displayName = value?.trim() ?? '';

                    if (displayName.isEmpty) {
                      return 'Podaj nazwę użytkownika';
                    }

                    if (displayName.length > 40) {
                      return 'Nazwa może mieć maksymalnie 40 znaków';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Podaj email';
                  }

                  if (!email.contains('@')) {
                    return 'Podaj poprawny email';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                obscureText: _obscurePassword,
                textInputAction: _isRegisterMode
                    ? TextInputAction.next
                    : TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_loading && !_isRegisterMode) {
                    _handleSubmit();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Pokaż hasło' : 'Ukryj hasło',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj hasło';
                  }

                  if (_isRegisterMode && value.length < 8) {
                    return 'Hasło musi mieć co najmniej 8 znaków';
                  }

                  return null;
                },
              ),
              if (_isRegisterMode) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmPasswordController,
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_loading) {
                      _handleSubmit();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Powtórz hasło',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Powtórz hasło';
                    }

                    if (value != _passwordController.text) {
                      return 'Hasła nie są takie same';
                    }

                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              SignInButton(
                loading: _loading,
                label: _isRegisterMode ? 'Zarejestruj się' : 'Zaloguj się',
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _toggleMode,
                child: Text(
                  _isRegisterMode
                      ? 'Masz już konto? Zaloguj się'
                      : 'Nie masz konta? Zarejestruj się',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
