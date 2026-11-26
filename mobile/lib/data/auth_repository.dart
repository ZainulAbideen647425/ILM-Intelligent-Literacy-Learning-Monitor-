/// Teacher sign-in. The frontend sprint uses [MockAuthRepository]; the real
/// implementation calls the Django API (JWT) without changing the UI.
abstract interface class AuthRepository {
  /// Returns null on success, or an AppStrings key describing the problem.
  Future<String?> signIn(String email, String password);
}

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const int minPasswordLength = 8;

  @override
  Future<String?> signIn(String email, String password) async {
    if (!_email.hasMatch(email.trim())) return 'invalidEmail';
    if (password.length < minPasswordLength) return 'passwordTooShort';
    return null;
  }
}
