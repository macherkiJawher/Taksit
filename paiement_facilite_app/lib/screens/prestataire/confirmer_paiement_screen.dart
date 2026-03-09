import 'package:flutter/material.dart';
import '../../services/mensualite_service.dart';
import '../../services/echeancier_service.dart';
import '../prestataire/echeancier_details_screen.dart';

class ConfirmerPaiementScreen extends StatefulWidget {
  final int mensualiteId;
  final String clientNom;
  final double montant;
  final String dateEcheance;
  final int echeancierId;

  const ConfirmerPaiementScreen({
    super.key,
    required this.mensualiteId,
    required this.clientNom,
    required this.montant,
    required this.dateEcheance,
    required this.echeancierId,
  });

  @override
  State<ConfirmerPaiementScreen> createState() =>
      _ConfirmerPaiementScreenState();
}

class _ConfirmerPaiementScreenState extends State<ConfirmerPaiementScreen> {
  bool _loading = false;

  Future<void> _confirmer() async {
    setState(() => _loading = true);
    try {
      await MensualiteService.payer(widget.mensualiteId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Paiement validé avec succès !"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Retourner aux détails de l'échéancier
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EcheancierDetailsScreen(
            echeancierId: widget.echeancierId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Confirmer paiement"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // Icône succès scan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.green, size: 60),
            ),

            const SizedBox(height: 16),

            const Text(
              "QR Code scanné avec succès",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // Détails paiement
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  const Text(
                    "Détails du paiement",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailRow(Icons.person, "Client", widget.clientNom),
                  const Divider(height: 20),
                  _detailRow(Icons.payments, "Montant",
                      "${widget.montant.toStringAsFixed(2)} DT",
                      valueColor: Colors.indigo),
                  const Divider(height: 20),
                  _detailRow(Icons.calendar_today, "Échéance",
                      widget.dateEcheance),
                  const Divider(height: 20),
                  _detailRow(Icons.tag, "Mensualité ID",
                      "#${widget.mensualiteId}"),
                ],
              ),
            ),

            const Spacer(),

            // Boutons
            Row(
              children: [
                // Annuler
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Annuler"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(width: 12),

                // Confirmer
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _loading ? "Validation..." : "Confirmer le paiement",
                      style: const TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _loading ? null : _confirmer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 10),
        Text("$label : ",
            style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}