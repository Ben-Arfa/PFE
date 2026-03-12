/// Exception métier lancée par AuthService avec un message lisible
/// et le champ concerné pour cibler l'icône du snackbar.
///
/// [field] : 'name' | 'email' | 'password' | null
class AuthException implements Exception {
  final String message;
  final String? field;

  AuthException(this.message, {this.field});

  @override
  String toString() => message;
}
