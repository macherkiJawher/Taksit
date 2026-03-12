import 'package:flutter/material.dart';
import '../../models/echeancier.dart';
import '../../services/echeancier_service.dart';
import '../../services/pdf_service.dart';
import '../../core/storage/token_storage.dart';
import '../../core/constants/api_config.dart';

class ClientEcheancierDetailsScreen extends StatefulWidget {
  final int echeancierId;
  const ClientEcheancierDetailsScreen({super.key, required this.echeancierId});

  @override
  State<ClientEcheancierDetailsScreen> createState() =>
      _ClientEcheancierDetailsScreenState();
}

class _ClientEcheancierDetailsScreenState
    extends State<ClientEcheancierDetailsScreen> {
  Echeancier? echeancier;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final e = await EcheancierService.getById(widget.echeancierId);
      setState(() {
        echeancier = e;
        loading = false;
      });
    } catch (err) {
      debugPrint("❌ Erreur chargement échéancier: $err");
      setState(() => loading = false);
    }
  }

  Future<void> _exporterPdf() async {
    if (echeancier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Données non chargées")),
      );
      return;
    }
    try {
      await PdfService.exporterEcheancier(
        echeancier: echeancier!,
        nomClient: echeancier!.clientNom,
        nomPrestataire: echeancier!.prestataireNom,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur PDF: $e")),
      );
    }
  }

  // ✅ Afficher QR Code dans un dialog
  Future<void> _afficherQrCode(int mensualiteId) async {
    final token = await TokenStorage.getToken();
    final url = "${ApiConfig.baseUrl}/mensualites/$mensualiteId/qrcode";

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.qr_code_2, color: Colors.indigo, size: 36),
            SizedBox(height: 8),
            Text(
              "QR Code de paiement",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Présentez ce QR Code au prestataire pour valider votre paiement",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.indigo.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Image.network(
                url,
                headers: {"Authorization": "Bearer $token"},
                width: 200,
                height: 200,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.indigo),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text("Impossible de charger\nle QR Code",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ce QR Code est unique à cette mensualité",
                      style: TextStyle(
                          fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer",
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Color _statutColor(String s) {
    switch (s) {
      case 'PAYEE':
        return Colors.green;
      case 'EN_RETARD':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statutIcon(String s) {
    switch (s) {
      case 'PAYEE':
        return Icons.check_circle;
      case 'EN_RETARD':
        return Icons.warning_amber_rounded;
      default:
        return Icons.access_time;
    }
  }

  String _statutLabel(String s) {
    switch (s) {
      case 'PAYEE':
        return 'Payée';
      case 'EN_RETARD':
        return 'En retard';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (echeancier == null) {
      return const Scaffold(
        body: Center(child: Text("Échéancier introuvable")),
      );
    }

    final e = echeancier!;
    final payees =
        e.mensualites.where((m) => m.statut == 'PAYEE').length;
    final total = e.mensualites.length;
    final montantRestant = e.mensualites
        .where((m) => m.statut != 'PAYEE')
        .fold(0.0, (sum, m) => sum + m.montant);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Crédit #${e.id}"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Télécharger PDF",
            onPressed: _exporterPdf,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Résumé du crédit ─────────────────────────
            Container(
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header carte
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: Colors.indigo),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Crédit #${e.id}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              e.prestataireNom,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Badge statut
                      Container(
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
                          e.statut == 'EN_COURS'
                              ? 'En cours'
                              : e.statut == 'TERMINE'
                                  ? 'Terminé'
                                  : e.statut,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: e.statut == 'TERMINE'
                                ? Colors.green
                                : e.statut == 'ANNULE'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  _infoRow(Icons.payments, "Montant total",
                      "${e.montantTotal.toStringAsFixed(2)} DT"),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.account_balance_wallet,
                    "Restant à payer",
                    "${montantRestant.toStringAsFixed(2)} DT",
                    valueColor: montantRestant > 0
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _infoRow(Icons.calendar_month, "Date création",
                      e.dateCreation
                          .toLocal()
                          .toString()
                          .split(' ')[0]),
                  const SizedBox(height: 10),
                  _infoRow(Icons.repeat, "Mensualités",
                      "$total mensualité(s) de ${(e.montantTotal / total).toStringAsFixed(2)} DT"),

                  const SizedBox(height: 16),

                  // Progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$payees / $total payées",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "📅 Mensualités",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ── Liste mensualités ────────────────────────
            ...e.mensualites.map((m) {
              final isPaye = m.statut == 'PAYEE';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _statutColor(m.statut).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [

                      // Icône statut
                      CircleAvatar(
                        backgroundColor:
                            _statutColor(m.statut).withOpacity(0.15),
                        child: Icon(
                          _statutIcon(m.statut),
                          color: _statutColor(m.statut),
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Infos mensualité
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  fontSize: 12, color: Colors.grey),
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

                      // ✅ Bouton QR Code ou badge Payée
                      isPaye
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Payée",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.qr_code,
                                  size: 14),
                              label: const Text("QR Code",
                                  style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8)),
                              ),
                              onPressed: () =>
                                  _afficherQrCode(m.id),
                            ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
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