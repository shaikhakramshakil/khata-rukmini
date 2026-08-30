import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityService {
  static const String _salt = 'rukmini_khata_salt_v1_secure';

  /// Hashes a secret (PIN or password) with salt using SHA-256
  static String hashSecret(String secret) {
    if (secret.isEmpty) return '';
    final bytes = utf8.encode('$secret:$_salt');
    final digest = sha256.convert(bytes);
    return 'sha256:${digest.toString()}';
  }

  /// Verifies an input secret against a stored value.
  /// Returns a record with:
  /// - [isValid]: Whether the secret matched (either hashed or legacy plain text)
  /// - [needsMigration]: True if it matched a legacy plain-text value and should be re-saved as a hash.
  static ({bool isValid, bool needsMigration}) verifySecret(
    String input,
    String? storedValue,
  ) {
    if (storedValue == null || storedValue.isEmpty) {
      return (isValid: false, needsMigration: false);
    }

    final expectedHash = hashSecret(input);

    // 1. Check against hashed secret
    if (storedValue == expectedHash) {
      return (isValid: true, needsMigration: false);
    }

    // 2. Check against legacy plaintext secret (transparent migration support)
    if (storedValue == input) {
      return (isValid: true, needsMigration: true);
    }

    return (isValid: false, needsMigration: false);
  }
}
