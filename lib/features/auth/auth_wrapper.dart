import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../shell/app_shell.dart';
import 'login_screen.dart';
import 'setup_screen.dart';
import 'pin_lock_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final isPinUnlocked = ref.watch(pinUnlockedProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final shopSettingsAsync = ref.watch(shopSettingsProvider);

    if (!isLoggedIn) {
      final hasAdmin = prefs.getString('admin_username') != null;
      if (hasAdmin) {
        return const LoginScreen();
      } else {
        return const SetupScreen();
      }
    }

    return shopSettingsAsync.when(
      data: (settings) {
        final pin = settings.appPin;
        if (pin != null && pin.isNotEmpty && !isPinUnlocked) {
          return const PinLockScreen();
        }
        return const AppShell();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          const Scaffold(body: Center(child: Text('Error loading settings'))),
    );
  }
}
