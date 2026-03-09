class RegisterRequest {
  final String nomComplet;
  final String email;
  final String motDePasse;
  final String telephone;
  final String role;
  final String? nomBoutique;
  final String? adresseBoutique;

  RegisterRequest({
    required this.nomComplet,
    required this.email,
    required this.motDePasse,
    required this.telephone,
    required this.role,
    this.nomBoutique,
    this.adresseBoutique,
  });

  Map<String, dynamic> toJson() {
    return {
      "nomComplet": nomComplet,
      "email": email,
      "motDePasse": motDePasse,
      "telephone": telephone,
      "role": role,
      "nomBoutique": nomBoutique,
      "adresseBoutique": adresseBoutique,
    };
  }
}
