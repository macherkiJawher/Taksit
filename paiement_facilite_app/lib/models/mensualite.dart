class Mensualite {
  final int id;
  final int numero;
  final String dateEcheance;
  final double montant;
  final String statut;
  final String? datePaiement;      // ← ajouter
  final String? photoRecuPath;     // ← ajouter

  Mensualite({
    required this.id,
    required this.numero,
    required this.dateEcheance,
    required this.montant,
    required this.statut,
    this.datePaiement,             // ← ajouter
    this.photoRecuPath,            // ← ajouter
  });

  factory Mensualite.fromJson(Map<String, dynamic> json) {
    return Mensualite(
      id: json['id'],
      numero: json['numero'],
      dateEcheance: json['dateEcheance'],
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'],
      datePaiement: json['datePaiement'],        // ← ajouter
      photoRecuPath: json['photoRecuPath'],      // ← ajouter
    );
  }
}