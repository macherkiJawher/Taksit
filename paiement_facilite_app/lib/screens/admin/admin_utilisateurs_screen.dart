import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUtilisateursScreen extends StatefulWidget {
  const AdminUtilisateursScreen({super.key});

  @override
  State<AdminUtilisateursScreen> createState() =>
      _AdminUtilisateursScreenState();
}

class _AdminUtilisateursScreenState extends State<AdminUtilisateursScreen> {
  List<dynamic> tous = [];
  List<dynamic> filtres = [];
  bool loading = true;
  String _filtre = 'TOUS';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminService.getUtilisateurs();
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
      if (f == 'TOUS') {
        filtres = tous;
      } else {
        filtres = tous.where((u) => u['role'] == f).toList();
      }
    });
  }

  Future<void> _toggle(int id) async {
    try {
      final actif = await AdminService.toggleActif(id);
      setState(() {
        final index = tous.indexWhere((u) => u['id'] == id);
        if (index != -1) tous[index]['actif'] = actif;
        _appliquerFiltre(_filtre);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Utilisateurs"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: ['TOUS', 'CLIENT', 'PRESTATAIRE']
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

                // Liste
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtres.length,
                      itemBuilder: (_, i) {
                        final u = filtres[i];
                        final isClient = u['role'] == 'CLIENT';
                        final actif = u['actif'] ?? true;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isClient
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.teal.withOpacity(0.15),
                              child: Icon(
                                isClient ? Icons.person : Icons.store,
                                color: isClient ? Colors.blue : Colors.teal,
                              ),
                            ),
                            title: Text(
                              u['nomComplet'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: actif ? Colors.black : Colors.grey,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['email'] ?? '',
                                    style: const TextStyle(fontSize: 12)),
                                if (isClient)
                                  Text(
                                    "Score: ${u['scoreEligibilite']?.toStringAsFixed(0) ?? '0'}",
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.indigo),
                                  ),
                                if (!isClient)
                                  Text(
                                    "Boutique: ${u['nomBoutique'] ?? '-'}",
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.teal),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: actif
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    actif ? "Actif" : "Bloqué",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: actif ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: actif,
                                  onChanged: (_) => _toggle(u['id']),
                                  activeColor: Colors.deepPurple,
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