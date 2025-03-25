class Auth {
  final bool auth;
  final String stok;
  final int uid;
  final List<Role> roles;
  final bool passwordReset;
  final String message;

  Auth({
    required this.auth,
    required this.stok,
    required this.uid,
    required this.roles,
    required this.passwordReset,
    required this.message,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      auth: json['auth'],
      stok: json['stok'],
      uid: json['uid'],
      roles: (json['roles'] as List).map((i) => Role.fromJson(i)).toList(),
      passwordReset: json['password_reset'],
      message: json['message'],
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], name: json['name']);
  }
}