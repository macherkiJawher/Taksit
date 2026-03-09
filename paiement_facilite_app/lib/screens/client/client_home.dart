import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/logout_helper.dart';
import '../../services/client_service.dart';
import '../../services/echeancier_service.dart';
import '../../services/alerte_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  Map<String, dynamic>? client;
  double? score;
  int totalEcheanciers = 0;
  int enCours = 0;
  int termines = 0;
  double montantRestant = 0;
  bool loading = true;
  int _nbAlertes = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _verifierAlertes();
  }

  // ✅ 1. Compter AVANT de notifier
  Future<void> _verifierAlertes() async {
    try {
      final role = await TokenStorage.getRole();
      if (role != 'CLIENT') return;

      debugPrint("🔍 Vérification alertes...");

      // ✅ Compter d'abord
      final count = await AlerteService.getNombreNonLues();
      debugPrint("📊 Nombre alertes non lues: $count");
      if (mounted) setState(() => _nbAlertes = count);

      // ✅ Afficher notifications ensuite
      await AlerteService.verifierEtNotifier();

    } catch (e) {
      debugPrint("❌ Erreur _verifierAlertes: $e");
    }
  }

  Future<void> _loadData() async {
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) return;

      final clientData = await ClientService.getById(userId);
      final scoreVal = await ClientService.getScoreById(userId);
      final echeanciers = await EcheancierService.getByClientId(userId);

      int cours = 0, done = 0;
      double restant = 0;

      for (final e in echeanciers) {
        if (e.statut == 'EN_COURS') cours++;
        if (e.statut == 'TERMINE') done++;
        for (final m in e.mensualites) {
          if (m.statut != 'PAYEE') restant += m.montant;
        }
      }

      setState(() {
        client = clientData;
        score = scoreVal;
        totalEcheanciers = echeanciers.length;
        enCours = cours;
        termines = done;
        montantRestant = restant;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  Color _scoreColor(double s) {
    if (s >= 70) return Colors.green;
    if (s >= 40) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel(double s) {
    if (s >= 70) return "Excellent";
    if (s >= 40) return "Acceptable";
    return "Insuffisant";
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style:
                  const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  // ✅ Ouvrir BottomSheet + marquer comme lues + reset badge
  void _ouvrirAlertes() async {
    // ✅ Afficher d'abord
    _afficherAlertes();

    // ✅ Marquer toutes comme lues
    final alertes = await AlerteService.getMesAlertes();
    for (final a in alertes) {
      if (a['id'] != null && a['lue'] == false) {
        await AlerteService.marquerLue(a['id']);
      }
    }

    // ✅ Reset badge
    if (mounted) setState(() => _nbAlertes = 0);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Client"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [

          // ✅ Cloche avec badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: "Notifications",
                onPressed: _ouvrirAlertes,  // ✅ utiliser _ouvrirAlertes
              ),
              if (_nbAlertes > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$_nbAlertes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.showLogoutDialog(context),
            tooltip: "Déconnexion",
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          await _verifierAlertes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 👋 Header
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
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bonjour 👋",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          client?['nomComplet'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📊 Score
              if (score != null) ...[
                const Text(
                  "Score d'éligibilité",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${score!.toStringAsFixed(1)} / 100",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _scoreColor(score!),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _scoreColor(score!)
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                _scoreLabel(score!),
                                style: TextStyle(
                                  color: _scoreColor(score!),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: score! / 100,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _scoreColor(score!)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          score! >= 40
                              ? "✅ Vous êtes éligible aux achats à crédit"
                              : "❌ Score insuffisant pour un crédit",
                          style: TextStyle(
                              color: _scoreColor(score!),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 📈 Statistiques
              const Text(
                "📈 Aperçu de vos crédits",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard("Total crédits",
                      totalEcheanciers.toString(),
                      Icons.list_alt, Colors.blue),
                  _statCard("En cours", enCours.toString(),
                      Icons.timelapse, Colors.orange),
                  _statCard("Terminés", termines.toString(),
                      Icons.check_circle, Colors.green),
                  _statCard(
                      "Restant à payer",
                      "${montantRestant.toStringAsFixed(0)} DT",
                      Icons.account_balance_wallet,
                      Colors.red),
                ],
              ),

              const SizedBox(height: 24),

              // 💡 Conseil
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lightbulb, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Payez vos mensualités à temps pour améliorer votre score d'éligibilité.",
                        style: TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ BottomSheet alertes
  void _afficherAlertes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,         // ✅ hauteur dynamique
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) =>
            FutureBuilder<List<dynamic>>(
          future: AlerteService.getMesAlertes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final alertes = snapshot.data!;

            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Titre
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🔔 Notifications (${alertes.length})",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text("Fermer"),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Liste
                Expanded(
                  child: alertes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                  Icons.notifications_none,
                                  size: 60,
                                  color: Colors.grey),
                              SizedBox(height: 12),
                              Text("Aucune notification",
                                  style: TextStyle(
                                      color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: alertes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final a = alertes[i];
                            final isRetard =
                                a['type'] == 'RETARD';
                            final isPaiement =
                                a['type'] == 'PAIEMENT';
                            final isNonLue =
                                a['lue'] == false;

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRetard
                                    ? Colors.red.shade50
                                    : isPaiement
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRetard
                                      ? Colors.red.shade200
                                      : isPaiement
                                          ? Colors.green.shade200
                                          : Colors.orange.shade200,
                                  width: isNonLue ? 2 : 1, // ✅ bordure épaisse si non lue
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isRetard
                                        ? Icons.warning_amber_rounded
                                        : isPaiement
                                            ? Icons.check_circle
                                            : Icons.calendar_today,
                                    color: isRetard
                                        ? Colors.red
                                        : isPaiement
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                a['titre'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                            // ✅ Point rouge si non lue
                                            if (isNonLue)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          a['message'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87),
                                        ),
                                        // ✅ Afficher la date si disponible
                                        if (a['date'] != null)
                                          Text(
                                            a['date'].toString().split('T')[0],
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}