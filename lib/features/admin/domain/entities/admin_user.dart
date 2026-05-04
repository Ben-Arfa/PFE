class AdminUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  const AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: (map['id'] ?? '').toString(),
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'user').toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
  };
}
