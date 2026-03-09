class PrestataireStats {
  final int totalEcheanciers;
  final int echeanciersEnCours;
  final int echeanciersTermines;
  final double montantTotal;
  final double montantPaye;

  PrestataireStats({
    required this.totalEcheanciers,
    required this.echeanciersEnCours,
    required this.echeanciersTermines,
    required this.montantTotal,
    required this.montantPaye,
  });

  factory PrestataireStats.fromJson(Map<String, dynamic> json) {
    return PrestataireStats(
      totalEcheanciers: json['totalEcheanciers'] ?? 0,
      echeanciersEnCours: json['echeanciersEnCours'] ?? 0,
      echeanciersTermines: json['echeanciersTermines'] ?? 0,
      montantTotal: (json['montantTotal'] ?? 0).toDouble(),
      montantPaye: (json['montantPaye'] ?? 0).toDouble(),
    );
  }
}
