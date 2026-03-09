import 'package:flutter/material.dart';
import '../../services/echeancier_service.dart';
import '../../services/client_service.dart';
import 'echeancier_details_screen.dart';

class CreerEcheancierScreen extends StatefulWidget {
  const CreerEcheancierScreen({super.key});

  @override
  State<CreerEcheancierScreen> createState() =>
      _CreerEcheancierScreenState();
}

class _CreerEcheancierScreenState extends State<CreerEcheancierScreen> {
  final nomClientCtrl = TextEditingController();
  final montantCtrl = TextEditingController();
  final nbCtrl = TextEditingController();

  double? score;
  bool loadingScore = false;
  bool loadingCreer = false;

  Future<void> verifierScore() async {
    if (nomClientCtrl.text.trim().isEmpty) return;
    setState(() {
      loadingScore = true;
      score = null;
    });
    try {
      final s = await ClientService.getScoreByName(nomClientCtrl.text);
      setState(() => score = s);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client non trouvé"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loadingScore = false);
    }
  }

  Future<void> creerEcheancier() async {
    if (nomClientCtrl.text.trim().isEmpty ||
        montantCtrl.text.trim().isEmpty ||
        nbCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (score != null && score! < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Client non éligible (score insuffisant)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loadingCreer = true);
    try {
      final e = await EcheancierService.creer(
        nomClient: nomClientCtrl.text,
        montant: double.parse(montantCtrl.text),
        nbMensualites: int.parse(nbCtrl.text),
      );
      if (!mounted) return;

      // ✅ push au lieu de pushReplacement → bouton retour fonctionne
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EcheancierDetailsScreen(echeancierId: e.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => loadingCreer = false);
    }
  }

  Color get _scoreColor {
    if (score == null) return Colors.grey;
    if (score! >= 70) return Colors.green;
    if (score! >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Créer un échéancier"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Section Client ───────────────────────────
            _sectionTitle("👤 Client"),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nomClientCtrl,
                    decoration: InputDecoration(
                      labelText: "Nom du client",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: loadingScore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user_outlined),
                      label: Text(loadingScore
                          ? "Vérification..."
                          : "Vérifier l'éligibilité"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: loadingScore ? null : verifierScore,
                    ),
                  ),

                  // Score badge
                  if (score != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _scoreColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            score! >= 40
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _scoreColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Score d'éligibilité : ${score!.toStringAsFixed(1)} / 100",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _scoreColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  score! >= 40
                                      ? "✅ Client éligible au crédit"
                                      : "❌ Score insuffisant",
                                  style: TextStyle(
                                      fontSize: 12, color: _scoreColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section Crédit ───────────────────────────
            _sectionTitle("💳 Détails du crédit"),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: montantCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Montant total (DT)",
                      prefixIcon: const Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nbCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Nombre de mensualités",
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  // Aperçu mensualité
                  if (montantCtrl.text.isNotEmpty &&
                      nbCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.indigo, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "≈ ${_calculerMensualite()} DT / mois",
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Bouton créer ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: loadingCreer
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(
                  loadingCreer
                      ? "Création en cours..."
                      : "Créer l'échéancier",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: loadingCreer ? null : creerEcheancier,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  String _calculerMensualite() {
    try {
      final montant = double.parse(montantCtrl.text);
      final nb = int.parse(nbCtrl.text);
      if (nb == 0) return "-";
      return (montant / nb).toStringAsFixed(2);
    } catch (_) {
      return "-";
    }
  }
}