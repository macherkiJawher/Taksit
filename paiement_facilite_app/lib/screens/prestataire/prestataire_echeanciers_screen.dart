import 'package:flutter/material.dart';
import '../../models/echeancier.dart';
import '../../services/echeancier_service.dart';
import 'echeancier_details_screen.dart';

enum SortType { date, montant }

class PrestataireEcheanciersScreen extends StatefulWidget {
  const PrestataireEcheanciersScreen({super.key});

  @override
  State<PrestataireEcheanciersScreen> createState() =>
      _PrestataireEcheanciersScreenState();
}

class _PrestataireEcheanciersScreenState
    extends State<PrestataireEcheanciersScreen> {
  late Future<List<Echeancier>> _future;
  List<Echeancier> _all = [];
  List<Echeancier> _filtered = [];
  String _search = '';
  String _statut = 'TOUS';
  SortType _sortType = SortType.date;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Echeancier>> _load() async {
    final list = await EcheancierService.getAllPrestataire();
    _all = list;
    _applyFilters();
    return list;
  }

  void _applyFilters() {
    List<Echeancier> data = [..._all];
    if (_search.isNotEmpty) {
      data = data
          .where(
            (e) => e.clientNom.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
    }
    if (_statut != 'TOUS') {
      data = data.where((e) => e.statut == _statut).toList();
    }
    data.sort((a, b) {
      int result = _sortType == SortType.date
          ? a.dateCreation.compareTo(b.dateCreation)
          : a.montantTotal.compareTo(b.montantTotal);
      return _ascending ? result : -result;
    });
    setState(() => _filtered = data);
  }

  Color _statutColor(String s) {
    if (s == 'EN_COURS') return Colors.orange;
    if (s == 'TERMINE') return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Mes Échéanciers"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Echeancier>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Barre recherche + filtres
              Container(
                color: Colors.indigo,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) {
                        _search = v;
                        _applyFilters();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Rechercher par client...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Filtre statut
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['TOUS', 'EN_COURS', 'TERMINE']
                                  .map(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          _statut = f;
                                          _applyFilters();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statut == f
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            f == 'TOUS'
                                                ? 'Tous'
                                                : f == 'EN_COURS'
                                                ? 'En cours'
                                                : 'Terminés',
                                            style: TextStyle(
                                              color: _statut == f
                                                  ? Colors.indigo
                                                  : Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        // Tri
                        IconButton(
                          icon: Icon(
                            _ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            _ascending = !_ascending;
                            _applyFilters();
                          },
                        ),
                        PopupMenuButton<SortType>(
                          icon: const Icon(Icons.sort, color: Colors.white),
                          onSelected: (v) {
                            _sortType = v;
                            _applyFilters();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: SortType.date,
                              child: Text("Par date"),
                            ),
                            PopupMenuItem(
                              value: SortType.montant,
                              child: Text("Par montant"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Compteur résultats
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      "${_filtered.length} échéancier(s)",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: _all.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              "Aucun échéancier",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                    ? const Center(child: Text("Aucun résultat"))
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _future = _load();
                          });
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final e = _filtered[i];
                            final payees = e.mensualites
                                .where((m) => m.statut == 'PAYEE')
                                .length;
                            final total = e.mensualites.length;
                            final prog = total == 0 ? 0.0 : payees / total;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EcheancierDetailsScreen(
                                      echeancierId: e.id,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.indigo,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                e.clientNom,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statutColor(
                                                e.statut,
                                              ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              e.statut == 'EN_COURS'
                                                  ? 'En cours'
                                                  : e.statut == 'TERMINE'
                                                  ? 'Terminé'
                                                  : e.statut,
                                              style: TextStyle(
                                                color: _statutColor(e.statut),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.payments,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${e.montantTotal.toStringAsFixed(0)} DT  •  ${e.nombreMensualites} mois",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            e.dateCreation
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "$payees / $total payées",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "${(prog * 100).toStringAsFixed(0)}%",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: prog == 1
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
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
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
