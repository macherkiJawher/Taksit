import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminGraphiquesScreen extends StatefulWidget {
  const AdminGraphiquesScreen({super.key});

  @override
  State<AdminGraphiquesScreen> createState() =>
      _AdminGraphiquesScreenState();
}

class _AdminGraphiquesScreenState extends State<AdminGraphiquesScreen> {
  Map<String, dynamic>? stats;
  List<dynamic> parMois = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await AdminService.getStats();
      final m = await AdminService.getStatsParMois();
      setState(() {
        stats = s;
        parMois = m;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Graphiques"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Répartition utilisateurs ──────────────
                    const Text("👥 Répartition utilisateurs",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _barreGraphique(
                              label: "Clients",
                              valeur: (stats?['totalClients'] ?? 0).toDouble(),
                              total: ((stats?['totalClients'] ?? 0) +
                                      (stats?['totalPrestataires'] ?? 0))
                                  .toDouble(),
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            _barreGraphique(
                              label: "Prestataires",
                              valeur: (stats?['totalPrestataires'] ?? 0)
                                  .toDouble(),
                              total: ((stats?['totalClients'] ?? 0) +
                                      (stats?['totalPrestataires'] ?? 0))
                                  .toDouble(),
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Statut crédits ────────────────────────
                    const Text("💳 Statut des crédits",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _barreGraphique(
                              label: "En cours",
                              valeur: (stats?['echeancierEnCours'] ?? 0)
                                  .toDouble(),
                              total:
                                  (stats?['totalEcheanciers'] ?? 1).toDouble(),
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            _barreGraphique(
                              label: "Terminés",
                              valeur: (stats?['echeancierTermines'] ?? 0)
                                  .toDouble(),
                              total:
                                  (stats?['totalEcheanciers'] ?? 1).toDouble(),
                              color: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _barreGraphique(
                              label: "Retards",
                              valeur: (stats?['mensualitesEnRetard'] ?? 0)
                                  .toDouble(),
                              total:
                                  (stats?['totalEcheanciers'] ?? 1).toDouble(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Finances ──────────────────────────────
                    const Text("💰 Recouvrement financier",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _barreGraphique(
                              label: "Recouvré",
                              valeur:
                                  (stats?['montantRecouvre'] ?? 0).toDouble(),
                              total: (stats?['montantTotal'] ?? 1).toDouble(),
                              color: Colors.green,
                              suffixe: "DT",
                            ),
                            const SizedBox(height: 12),
                            _barreGraphique(
                              label: "Restant",
                              valeur: ((stats?['montantTotal'] ?? 0) -
                                      (stats?['montantRecouvre'] ?? 0))
                                  .toDouble(),
                              total: (stats?['montantTotal'] ?? 1).toDouble(),
                              color: Colors.red,
                              suffixe: "DT",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Crédits par mois ──────────────────────
                    const Text("📅 Crédits créés par mois",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: parMois.isEmpty
                            ? const Center(
                                child: Text("Aucune donnée",
                                    style:
                                        TextStyle(color: Colors.grey)))
                            : Column(
                                children: parMois.map((m) {
                                  final maxVal = parMois
                                      .map((x) =>
                                          (x['nombre'] as num).toDouble())
                                      .reduce((a, b) => a > b ? a : b);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: _barreGraphique(
                                      label: m['mois'].toString(),
                                      valeur:
                                          (m['nombre'] as num).toDouble(),
                                      total: maxVal,
                                      color: Colors.deepPurple,
                                      afficherPourcentage: false,
                                      suffixe: " crédit(s)",
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _barreGraphique({
    required String label,
    required double valeur,
    required double total,
    required Color color,
    String suffixe = "",
    bool afficherPourcentage = true,
  }) {
    final ratio = total == 0 ? 0.0 : (valeur / total).clamp(0.0, 1.0);
    final pct = (ratio * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
              afficherPourcentage
                  ? "${valeur.toStringAsFixed(0)}$suffixe ($pct%)"
                  : "${valeur.toStringAsFixed(0)}$suffixe",
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}