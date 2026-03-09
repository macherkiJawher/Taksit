import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';

class RechercheClientScreen extends StatefulWidget {
  const RechercheClientScreen({super.key});

  @override
  State<RechercheClientScreen> createState() =>
      _RechercheClientScreenState();
}

class _RechercheClientScreenState extends State<RechercheClientScreen> {
  final TextEditingController nomController = TextEditingController();
  List<Client> clients = [];
  bool loading = false;
  bool _searched = false;

  Future<void> search() async {
    if (nomController.text.trim().isEmpty) return;
    setState(() {
      loading = true;
      _searched = true;
    });
    try {
      final data =
          await ClientService.searchByName(nomController.text.trim());
      setState(() => clients = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de recherche")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Color _scoreColor(double s) {
    if (s >= 70) return Colors.green;
    if (s >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Recherche Client"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nomController,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => search(),
                    decoration: InputDecoration(
                      hintText: "Nom du client...",
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.person_search,
                          color: Colors.white.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: loading ? null : search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : !_searched
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text("Recherchez un client par nom",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : clients.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 60, color: Colors.grey),
                                SizedBox(height: 12),
                                Text("Aucun client trouvé",
                                    style:
                                        TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: clients.length,
                            itemBuilder: (_, i) {
                              final c = clients[i];
                              final color =
                                  _scoreColor(c.scoreEligibilite);

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Colors.indigo.withOpacity(0.1),
                                        child: Text(
                                          c.nomComplet.isNotEmpty
                                              ? c.nomComplet[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.indigo,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.nomComplet,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(c.email,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                            Text(c.telephone,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color:
                                                  color.withOpacity(0.3)),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              c.scoreEligibilite
                                                  .toStringAsFixed(0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "score",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}