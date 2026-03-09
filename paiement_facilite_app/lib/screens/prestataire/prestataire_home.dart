import 'package:flutter/material.dart';
import '../../core/utils/logout_helper.dart';
import '../../models/prestataire.dart';
import '../../models/prestataire_stats.dart';
import '../../services/prestataire_service.dart';
import 'recherche_client_screen.dart';
import 'scanner_screen.dart';

class PrestataireHome extends StatefulWidget {
  const PrestataireHome({super.key});

  @override
  State<PrestataireHome> createState() => _PrestataireHomeState();
}

class _PrestataireHomeState extends State<PrestataireHome> {
  Prestataire? prestataire;
  PrestataireStats? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final p = await PrestataireService.getMe();
      final s = await PrestataireService.getStats(p.id);
      setState(() {
        prestataire = p;
        stats = s;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final progression = stats!.montantTotal == 0
        ? 0.0
        : stats!.montantPaye / stats!.montantTotal;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Espace Prestataire"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.showLogoutDialog(context),
            tooltip: "Déconnexion",
          ),
        ],
      ),

      // ✅ Bouton Scanner QR Code
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        elevation: 4,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text(
          "Scanner QR",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScannerScreen()),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.store,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bonjour 👋",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13),
                          ),
                          Text(
                            prestataire!.nomComplet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            prestataire!.nomBoutique,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Banner Scanner ───────────────────────────
              // ✅ Bannière rapide pour scanner
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScannerScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade700,
                        Colors.indigo.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_scanner,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scanner un paiement",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Scannez le QR Code du client pour valider",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Recherche client ─────────────────────────
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RechercheClientScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.search,
                            color: Colors.indigo, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Rechercher un client...",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Statistiques ─────────────────────────────
              const Text("📊 Aperçu",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard("Total crédits",
                      stats!.totalEcheanciers.toString(),
                      Icons.list_alt, Colors.blue),
                  _statCard("En cours",
                      stats!.echeanciersEnCours.toString(),
                      Icons.timelapse, Colors.orange),
                  _statCard("Terminés",
                      stats!.echeanciersTermines.toString(),
                      Icons.check_circle, Colors.green),
                  _statCard("Montant payé",
                      "${stats!.montantPaye.toStringAsFixed(0)} DT",
                      Icons.payments, Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

              // ── Progression paiements ────────────────────
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("💰 Progression des paiements",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _miniStat(
                            "Total",
                            "${stats!.montantTotal.toStringAsFixed(0)} DT",
                            Colors.indigo),
                        _miniStat(
                            "Payé",
                            "${stats!.montantPaye.toStringAsFixed(0)} DT",
                            Colors.green),
                        _miniStat(
                            "Restant",
                            "${(stats!.montantTotal - stats!.montantPaye).toStringAsFixed(0)} DT",
                            Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${(progression * 100).toStringAsFixed(0)}% recouvré",
                      style: TextStyle(
                        fontSize: 12,
                        color: progression == 1
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progression,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progression == 1
                              ? Colors.green
                              : Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Infos prestataire ────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ℹ️ Informations personnelles",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _infoRow(Icons.email_outlined, prestataire!.email),
                    const SizedBox(height: 10),
                    _infoRow(
                        Icons.phone_outlined, prestataire!.telephone),
                    const SizedBox(height: 10),
                    _infoRow(Icons.location_on_outlined,
                        prestataire!.adresseBoutique),
                  ],
                ),
              ),

              // ✅ Espace pour ne pas cacher le FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}