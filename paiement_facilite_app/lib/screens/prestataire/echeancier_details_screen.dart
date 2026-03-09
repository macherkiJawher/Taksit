import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/echeancier.dart';
import '../../services/echeancier_service.dart';
import '../../services/mensualite_service.dart';
import '../../services/pdf_service.dart';

class EcheancierDetailsScreen extends StatefulWidget {
  final int echeancierId;
  const EcheancierDetailsScreen({super.key, required this.echeancierId});

  @override
  State<EcheancierDetailsScreen> createState() =>
      _EcheancierDetailsScreenState();
}

class _EcheancierDetailsScreenState extends State<EcheancierDetailsScreen> {
  late Future<Echeancier> future;
  Echeancier? _echeancier;

  @override
  void initState() {
    super.initState();
    future = EcheancierService.getById(widget.echeancierId).then((e) {
      _echeancier = e;
      return e;
    });
  }

  Color _couleur(String s) {
    switch (s) {
      case 'PAYEE':     return Colors.green;
      case 'EN_RETARD': return Colors.red;
      default:          return Colors.orange;
    }
  }

  IconData _icone(String s) {
    switch (s) {
      case 'PAYEE':     return Icons.check_circle;
      case 'EN_RETARD': return Icons.warning_amber_rounded;
      default:          return Icons.access_time;
    }
  }

  String _label(String s) {
    switch (s) {
      case 'PAYEE':     return 'Payée';
      case 'EN_RETARD': return 'En retard';
      default:          return 'En attente';
    }
  }

  Future<void> _exporterPdf() async {
    if (_echeancier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Données non chargées")),
      );
      return;
    }
    try {
      await PdfService.exporterEcheancier(
        echeancier: _echeancier!,
        nomClient: _echeancier!.clientNom,
        nomPrestataire: _echeancier!.prestataireNom,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur PDF: $e")),
      );
    }
  }

  Future<void> _payerAvecPhoto(int mensualiteId) async {
    final choix = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Valider le paiement"),
        content: const Text("Voulez-vous ajouter une photo du reçu ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'sans'),
            child: const Text("Sans photo"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Avec photo"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () => Navigator.pop(context, 'avec'),
          ),
        ],
      ),
    );

    if (choix == null) return;

    try {
      if (choix == 'sans') {
        await MensualiteService.payer(mensualiteId);
      } else {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (image == null) return;
        await MensualiteService.payerAvecRecu(
          mensualiteId: mensualiteId,
          imagePath: image.path,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Paiement validé avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        future = EcheancierService.getById(widget.echeancierId).then((e) {
          _echeancier = e;
          return e;
        });
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Détails Échéancier"),
  backgroundColor: Colors.indigo,
  foregroundColor: Colors.white,
  // ✅ Ajouter le bouton retour manuel
  leading: Navigator.canPop(context)
      ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      : null,
  actions: [
    IconButton(
      icon: const Icon(Icons.picture_as_pdf),
      tooltip: "Exporter PDF",
      onPressed: _exporterPdf,
    ),
  ],
),
      body: FutureBuilder<Echeancier>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Échéancier introuvable"));
          }

          final e = snapshot.data!;
          final payees =
              e.mensualites.where((m) => m.statut == 'PAYEE').length;
          final total = e.mensualites.length;
          final montantRestant = e.mensualites
              .where((m) => m.statut != 'PAYEE')
              .fold(0.0, (sum, m) => sum + m.montant);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                future =
                    EcheancierService.getById(widget.echeancierId).then((e) {
                  _echeancier = e;
                  return e;
                });
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ── Résumé ────────────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Row(
                          children: [
                            const Icon(Icons.receipt_long,
                                color: Colors.indigo),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Crédit #${e.id}  —  ${e.clientNom}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 20),

                        _infoRow(Icons.payments, "Montant total",
                            "${e.montantTotal.toStringAsFixed(2)} DT"),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.account_balance_wallet,
                          "Restant à payer",
                          "${montantRestant.toStringAsFixed(2)} DT",
                          valueColor: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.store,
                          "Prestataire",
                          e.prestataireNom,
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.calendar_today,
                          "Date création",
                          e.dateCreation
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),

                        const SizedBox(height: 14),

                        // Progression
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$payees / $total payées",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              "${(total == 0 ? 0 : payees / total * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: payees == total
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : payees / total,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              payees == total
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Badge statut
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: e.statut == 'TERMINE'
                                  ? Colors.green.withOpacity(0.15)
                                  : e.statut == 'ANNULE'
                                      ? Colors.red.withOpacity(0.15)
                                      : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              e.statut,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: e.statut == 'TERMINE'
                                    ? Colors.green
                                    : e.statut == 'ANNULE'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "📅 Mensualités",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // ── Liste mensualités ──────────────────────────────
                ...e.mensualites.map((m) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: _couleur(m.statut).withOpacity(0.4),
                          width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [

                          // Icône statut
                          CircleAvatar(
                            backgroundColor:
                                _couleur(m.statut).withOpacity(0.15),
                            child: Icon(_icone(m.statut),
                                color: _couleur(m.statut), size: 20),
                          ),

                          const SizedBox(width: 12),

                          // Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mensualité ${m.numero}  —  "
                                  "${m.montant.toStringAsFixed(2)} DT",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Échéance : ${m.dateEcheance}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                                if (m.datePaiement != null)
                                  Text(
                                    "Payée le : ${m.datePaiement}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Bouton ou badge
                          m.statut != 'PAYEE'
                              ? ElevatedButton.icon(
                                  icon: const Icon(Icons.check,
                                      size: 14),
                                  label: const Text("Payer",
                                      style:
                                          TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                8)),
                                  ),
                                  onPressed: () =>
                                      _payerAvecPhoto(m.id),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _label(m.statut),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 10),
        Text("$label : ",
            style:
                const TextStyle(color: Colors.black54, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: valueColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}