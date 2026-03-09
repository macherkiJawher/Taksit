import 'mensualite.dart';

class Echeancier {
  final int id;
  final double montantTotal;
  final int nombreMensualites;
  final String statut;
  final String clientNom;
  final String prestataireNom; // ✅ ajouter
  final DateTime dateCreation;
  final List<Mensualite> mensualites;

  Echeancier({
    required this.id,
    required this.montantTotal,
    required this.nombreMensualites,
    required this.statut,
    required this.clientNom,
    required this.prestataireNom, // ✅ ajouter
    required this.dateCreation,
    required this.mensualites,
  });

  factory Echeancier.fromJson(Map<String, dynamic> json) {
    return Echeancier(
      id: json['id'],
      montantTotal: (json['montantTotal'] as num).toDouble(),
      nombreMensualites: json['nombreMensualites'],
      statut: json['statut'] ?? 'INCONNU',

      clientNom: json['client'] != null
          ? json['client']['nomComplet'] ?? 'Client inconnu'
          : 'Client inconnu',

      // ✅ ajouter
      prestataireNom: json['prestataire'] != null
          ? json['prestataire']['nomBoutique'] ?? 'Prestataire inconnu'
          : 'Prestataire inconnu',

      dateCreation: DateTime.parse(json['dateCreation']),

      mensualites: (json['mensualites'] as List? ?? [])
          .map((m) => Mensualite.fromJson(m))
          .toList(),
    );
  }
}