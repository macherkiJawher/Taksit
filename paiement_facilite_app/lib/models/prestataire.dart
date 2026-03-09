class Prestataire {
  final int id;
  final String nomComplet;
  final String email;
  final String telephone;
  final String nomBoutique;
  final String adresseBoutique;
  final String societe;

  Prestataire({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.nomBoutique,
    required this.adresseBoutique,
    required this.societe,
  });

  factory Prestataire.fromJson(Map<String, dynamic> json) {
    return Prestataire(
      id: json['id'],
      nomComplet: json['nomComplet'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      nomBoutique: json['nomBoutique'] ?? '',
      adresseBoutique: json['adresseBoutique'] ?? '',
      societe: json['societe'] ?? '',
    );
  }
}
