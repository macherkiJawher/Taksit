class AuthResponse {
  final int id;
  final String role;
  final String token;

  AuthResponse({
    required this.id,
    required this.role,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'],
      role: json['role'],
      token: json['token'],
    );
  }
}
