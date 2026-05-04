class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserProfile(
        firstName: '',
        lastName: '',
        email: '',
        role: 'user',
      );
    }
    return UserProfile(
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'user').toString().toLowerCase().trim(),
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
  };
}
