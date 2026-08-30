import 'package:shared_preferences/shared_preferences.dart';

class LockoutService {
  final SharedPreferences _prefs;
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 1);

  LockoutService(this._prefs);

  String _attemptsKey(String scope) => '${scope}_failed_attempts';
  String _lockoutKey(String scope) => '${scope}_lockout_until';

  int getFailedAttempts(String scope) {
    return _prefs.getInt(_attemptsKey(scope)) ?? 0;
  }

  DateTime? getLockoutUntil(String scope) {
    final epoch = _prefs.getInt(_lockoutKey(scope));
    if (epoch == null) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(epoch);
    if (DateTime.now().isBefore(until)) {
      return until;
    } else {
      _prefs.remove(_lockoutKey(scope));
      return null;
    }
  }

  bool isLockedOut(String scope) {
    return getLockoutUntil(scope) != null;
  }

  int getRemainingSeconds(String scope) {
    final until = getLockoutUntil(scope);
    if (until == null) return 0;
    final diff = until.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<bool> recordFailure(String scope) async {
    int attempts = getFailedAttempts(scope) + 1;
    if (attempts >= maxAttempts) {
      final until = DateTime.now().add(lockoutDuration);
      await _prefs.setInt(_lockoutKey(scope), until.millisecondsSinceEpoch);
      await _prefs.setInt(_attemptsKey(scope), 0);
      return true; // Newly locked out
    } else {
      await _prefs.setInt(_attemptsKey(scope), attempts);
      return false;
    }
  }

  Future<void> recordSuccess(String scope) async {
    await _prefs.remove(_attemptsKey(scope));
    await _prefs.remove(_lockoutKey(scope));
  }
}
