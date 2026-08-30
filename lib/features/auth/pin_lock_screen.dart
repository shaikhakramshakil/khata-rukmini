import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/security_service.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlock() async {
    setState(() => _error = null);
    final lockoutService = ref.read(lockoutServiceProvider);
    const scope = 'pin_unlock';

    if (lockoutService.isLockedOut(scope)) {
      final secondsLeft = lockoutService.getRemainingSeconds(scope);
      setState(() {
        _error = 'Too many failed attempts. Try again in $secondsLeft seconds.';
      });
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      if (!mounted) return;
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      final correctPin = settings.appPin;

      if (correctPin == null || correctPin.isEmpty) {
        // Fallback if somehow they reach here without a PIN
        ref.read(pinUnlockedProvider.notifier).unlock();
        return;
      }

      final pinVerification = SecurityService.verifySecret(
        _pinController.text.trim(),
        correctPin,
      );

      if (pinVerification.isValid) {
        // Transparent migration if PIN was stored as plain text
        if (pinVerification.needsMigration) {
          await ref
              .read(settingsRepositoryProvider)
              .updateSettings(
                appPin: SecurityService.hashSecret(_pinController.text.trim()),
              );
        }
        await lockoutService.recordSuccess(scope);
        if (mounted) ref.read(pinUnlockedProvider.notifier).unlock();
      } else {
        final newlyLockedOut = await lockoutService.recordFailure(scope);
        if (mounted) {
          setState(() {
            if (newlyLockedOut) {
              _error = 'Too many failed attempts. Locked out for 1 minute.';
            } else {
              _error = 'Invalid PIN. Please try again.';
            }
            _isLoading = false;
            _pinController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching settings: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _logout() {
    ref.read(isLoggedInProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.elevated,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text('App Locked', style: AppTypography.headingLarge),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter your PIN to unlock',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mute,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              Text('PIN', style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.ink),
                  ),
                ),
                onSubmitted: (_) => _unlock(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _unlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.elevated,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.elevated,
                            ),
                          ),
                        )
                      : Text('Unlock', style: AppTypography.button),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _logout,
                  child: Text(
                    'Log out instead',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
