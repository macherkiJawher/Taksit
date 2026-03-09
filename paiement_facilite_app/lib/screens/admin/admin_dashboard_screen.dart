import 'package:flutter/material.dart';
import '../../core/utils/logout_helper.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await AdminService.getStats();
      setState(() { stats = s; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Widget _card(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord Admin"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.showLogoutDialog(context),
          ),
        ],
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

                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👋 Bonjour, Admin",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 4),
                          Text("Vue d'ensemble de la plateforme",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("👥 Utilisateurs",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _card("Clients",
                            "${stats?['totalClients'] ?? 0}",
                            Icons.person, Colors.blue),
                        _card("Prestataires",
                            "${stats?['totalPrestataires'] ?? 0}",
                            Icons.store, Colors.teal),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text("💳 Crédits",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _card("Total crédits",
                            "${stats?['totalEcheanciers'] ?? 0}",
                            Icons.list_alt, Colors.indigo),
                        _card("En cours",
                            "${stats?['echeancierEnCours'] ?? 0}",
                            Icons.timelapse, Colors.orange),
                        _card("Terminés",
                            "${stats?['echeancierTermines'] ?? 0}",
                            Icons.check_circle, Colors.green),
                        _card("Retards",
                            "${stats?['mensualitesEnRetard'] ?? 0}",
                            Icons.warning_amber, Colors.red),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text("💰 Finances",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _card("Montant total",
                            "${(stats?['montantTotal'] ?? 0).toStringAsFixed(0)} DT",
                            Icons.payments, Colors.purple),
                        _card("Recouvré",
                            "${(stats?['montantRecouvre'] ?? 0).toStringAsFixed(0)} DT",
                            Icons.account_balance_wallet, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}