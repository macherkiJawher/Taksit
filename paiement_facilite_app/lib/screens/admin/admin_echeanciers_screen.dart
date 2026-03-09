import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminEcheancierScreen extends StatefulWidget {
  const AdminEcheancierScreen({super.key});

  @override
  State<AdminEcheancierScreen> createState() => _AdminEcheancierScreenState();
}

class _AdminEcheancierScreenState extends State<AdminEcheancierScreen> {
  List<dynamic> tous = [];
  List<dynamic> filtres = [];
  bool loading = true;
  String _filtre = 'TOUS';
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminService.getEcheanciers();
      setState(() {
        tous = data;
        _appliquerFiltre(_filtre);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _appliquerFiltre(String f) {
    setState(() {
      _filtre = f;
      var liste = f == 'TOUS'
          ? tous
          : tous.where((e) => e['statut'] == f).toList();
      if (_recherche.isNotEmpty) {
        liste = liste
            .where((e) =>
                e['clientNom']
                    .toString()
                    .toLowerCase()
                    .contains(_recherche.toLowerCase()) ||
                e['prestataireNom']
                    .toString()
                    .toLowerCase()
                    .contains(_recherche.toLowerCase()))
            .toList();
      }
      filtres = liste;
    });
  }

  Color _statutColor(String s) {
    if (s == 'EN_COURS') return Colors.orange;
    if (s == 'TERMINE') return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les crédits"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barre recherche
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher client ou prestataire...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) {
                      _recherche = v;
                      _appliquerFiltre(_filtre);
                    },
                  ),
                ),

                // Filtres statut
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: ['TOUS', 'EN_COURS', 'TERMINE', 'ANNULE']
                        .map((f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(f),
                                selected: _filtre == f,
                                onSelected: (_) => _appliquerFiltre(f),
                                selectedColor:
                                    Colors.deepPurple.withOpacity(0.2),
                                checkmarkColor: Colors.deepPurple,
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Liste
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtres.length,
                      itemBuilder: (_, i) {
                        final e = filtres[i];
                        final payees = e['mensualitesPayees'] ?? 0;
                        final total = e['mensualitesTotal'] ?? 1;
                        final prog = payees / total;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Crédit #${e['id']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statutColor(e['statut'])
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        e['statut'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _statutColor(e['statut']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "👤 ${e['clientNom']}  •  🏪 ${e['prestataireNom']}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${e['montantTotal'].toStringAsFixed(0)} DT  •  ${e['nombreMensualites']} mois",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("$payees / $total payées",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey)),
                                    Text(
                                      "${(prog * 100).toStringAsFixed(0)}%",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: prog == 1
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: prog,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      prog == 1
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
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