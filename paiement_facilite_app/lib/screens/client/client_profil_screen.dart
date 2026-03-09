// lib/screens/client/client_profil_screen.dart

import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/logout_helper.dart';
import '../../services/client_service.dart';

class ClientProfilScreen extends StatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  Map<String, dynamic>? client;
  double? score;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) return;
      final data = await ClientService.getById(userId);
      final s = await ClientService.getScoreById(userId);
      setState(() {
        client = data;
        score = s;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Color _scoreColor(double s) {
    if (s >= 70) return Colors.green;
    if (s >= 40) return Colors.orange;
    return Colors.red;
  }

  String _scoreDescription(double s) {
    if (s >= 70) return "Excellent profil de paiement. Vous êtes facilement éligible.";
    if (s >= 40) return "Profil acceptable. Continuez à payer vos mensualités à temps.";
    return "Score insuffisant. Payez vos mensualités en retard pour l'améliorer.";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.showLogoutDialog(context),
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 👤 Avatar et nom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      client?['nomComplet'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Client",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📊 Score d'éligibilité
              if (score != null) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📊 Score d'éligibilité",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: score! / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _scoreColor(score!),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${score!.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: _scoreColor(score!),
                                    ),
                                  ),
                                  Text(
                                    "/ 100",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _scoreColor(score!).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _scoreDescription(score!),
                            style: TextStyle(
                              fontSize: 13,
                              color: _scoreColor(score!),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ℹ️ Informations personnelles
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ℹ️ Informations personnelles",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _profilRow(Icons.person, "Nom complet",
                          client?['nomComplet'] ?? '-'),
                      const SizedBox(height: 14),
                      _profilRow(
                          Icons.email, "Email", client?['email'] ?? '-'),
                      const SizedBox(height: 14),
                      _profilRow(Icons.phone, "Téléphone",
                          client?['telephone'] ?? '-'),
                      const SizedBox(height: 14),
                      _profilRow(
                        Icons.calendar_today,
                        "Membre depuis",
                        client?['dateInscription'] != null
                            ? client!['dateInscription'].toString().split('T')[0]
                            : '-',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🚪 Bouton déconnexion
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => LogoutHelper.showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Se déconnecter",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profilRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.indigo),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}