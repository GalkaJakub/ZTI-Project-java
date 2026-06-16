import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/app_snack_bar.dart';
import 'package:wsp/core/widgets/async_page_view.dart';
import 'package:wsp/features/auth/login_page.dart';
import 'package:wsp/features/auth/services/auth_service.dart';
import 'package:wsp/features/profile/models/profile_user.dart';
import 'package:wsp/features/profile/services/profile_service.dart';
import 'package:wsp/features/profile/widgets/action_tile.dart';
import 'package:wsp/features/profile/widgets/info_tile.dart';
import 'package:wsp/features/profile/widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  final _authService = AuthService();

  late Future<ProfileUser> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getCurrentUser();
  }

  Future<void> _refreshProfile() {
    final profileFuture = _profileService.getCurrentUser();

    setState(() {
      _profileFuture = profileFuture;
    });

    return profileFuture.then((_) {});
  }

  Future<void> _changeDisplayName(ProfileUser user) async {
    final controller = TextEditingController(text: user.displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień nazwę'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Nazwa użytkownika',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.isEmpty || newName == user.displayName) {
      return;
    }

    try {
      final updatedUser = await _profileService.updateDisplayName(newName);

      if (!mounted) return;

      setState(() {
        _profileFuture = Future.value(updatedUser);
      });

      context.showAppSnackBar('Nazwa została zmieniona.');
    } catch (e) {
      if (!mounted) return;

      context.showAppSnackBar('Nie udało się zapisać: $e');
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wylogować?'),
          content: const Text('Po wylogowaniu wrócisz do ekranu logowania.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Wyloguj'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) {
      return;
    }

    await _authService.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: AsyncPageView<ProfileUser>(
        future: _profileFuture,
        onRefresh: _refreshProfile,
        errorTitle: 'Nie udało się pobrać profilu',
        builder: (context, user) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 20),
            InfoTile(
              icon: Icons.alternate_email,
              title: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 20),
            ActionTile(
              icon: Icons.edit_outlined,
              title: 'Nazwa',
              subtitle: 'Zmień wyświetlaną nazwę',
              onTap: () => _changeDisplayName(user),
            ),
            ActionTile(
              icon: Icons.logout,
              title: 'Wyloguj',
              subtitle: 'Wyloguj sie z konta',
              danger: true,
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
