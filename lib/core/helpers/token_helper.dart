import 'dart:math';

class TokenHelper {
  static String generateToken() {
    final random = Random();
    return 'TKN${1000 + random.nextInt(9000)}';
  }
}
