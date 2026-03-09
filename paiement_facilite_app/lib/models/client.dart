class Client {
  final int id;
  final String nomComplet;
  final String email;
  final String telephone;
  final double scoreEligibilite;

  Client({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.scoreEligibilite,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nomComplet: json['nomComplet'],
      email: json['email'],
      telephone: json['telephone'],
      scoreEligibilite: (json['scoreEligibilite'] ?? 0).toDouble(),
    );
  }
}
