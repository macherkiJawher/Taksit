// lib/screens/client/client_echeanciers_screen.dart

import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
import '../../models/echeancier.dart';
import '../../services/echeancier_service.dart';
import 'client_echeancier_details_screen.dart';

class ClientEcheanciersScreen extends StatefulWidget {
  const ClientEcheanciersScreen({super.key});

  @override
  State<ClientEcheanciersScreen> createState() =>
      _ClientEcheanciersScreenState();
}

class _ClientEcheanciersScreenState extends State<ClientEcheanciersScreen> {
  List<Echeancier> _all = [];
  List<Echeancier> _filtered = [];
  String _statut = 'TOUS';
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
      final list = await EcheancierService.getByClientId(userId);
      setState(() {
        _all = list;
        _applyFilter();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint(e.toString());
    }
  }

  void _applyFilter() {
    if (_statut == 'TOUS') {
      _filtered = [..._all];
    } else {
      _filtered = _all.where((e) => e.statut == _statut).toList();
    }
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'TERMINE':
        return Colors.green;
      case 'EN_COURS':
        return Colors.orange;
      case 'ANNULE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'TERMINE':
        return '✅ Terminé';
      case 'EN_COURS':
        return '⏳ En cours';
      case 'ANNULE':
        return '❌ Annulé';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Crédits"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres statut
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['TOUS', 'EN_COURS', 'TERMINE', 'ANNULE']
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    s == 'TOUS'
                                        ? 'Tous'
                                        : s == 'EN_COURS'
                                            ? 'En cours'
                                            : s == 'TERMINE'
                                                ? 'Terminés'
                                                : 'Annulés',
                                  ),
                                  selected: _statut == s,
                                  selectedColor: Colors.indigo,
                                  labelStyle: TextStyle(
                                    color: _statut == s
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _statut = s;
                                      _applyFilter();
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                // Liste
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun crédit trouvé",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final e = _filtered[index];
                              final payees = e.mensualites
                                  .where((m) => m.statut == 'PAYEE')
                                  .length;
                              final total = e.mensualites.length;
                              final progress =
                                  total == 0 ? 0.0 : payees / total;

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ClientEcheancierDetailsScreen(
                                          echeancierId: e.id,
                                        ),
                                      ),
                                    ).then((_) => _load());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Crédit #${e.id}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _statutColor(e.statut)
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                _statutLabel(e.statut),
                                                style: TextStyle(
                                                  color:
                                                      _statutColor(e.statut),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.payments_outlined,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${e.montantTotal.toStringAsFixed(2)} DT",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              e.dateCreation
                                                  .toLocal()
                                                  .toString()
                                                  .split(' ')[0],
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "$payees / $total mensualités payées",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              "${(progress * 100).toStringAsFixed(0)}%",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    _statutColor(e.statut),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 7,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    _statutColor(e.statut)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}