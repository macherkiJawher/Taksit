class Utilisateur {
  final int id;
  final String role;

  Utilisateur({required this.id, required this.role});

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['utilisateurId'],
      role: json['role'],
    );
  }
}
