import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/echeancier.dart';

class PdfService {

  static Future<void> exporterEcheancier({
    required Echeancier echeancier,
    required String nomClient,
    required String nomPrestataire,
  }) async {
    final pdf = pw.Document();

    final colorIndigo = PdfColor.fromHex('#3F51B5');
    final colorGrey = PdfColor.fromHex('#F5F5F5');
    final colorGreen = PdfColor.fromHex('#4CAF50');
    final colorOrange = PdfColor.fromHex('#FF9800');
    final colorRed = PdfColor.fromHex('#F44336');
    final colorWhite70 = PdfColor.fromHex('#B3FFFFFF'); // ✅ fix white70

    PdfColor statutColor(String statut) {
      if (statut == 'PAYEE') return colorGreen;
      if (statut == 'EN_RETARD') return colorRed;
      return colorOrange;
    }

    String statutLabel(String statut) {
      if (statut == 'PAYEE') return 'Payee';
      if (statut == 'EN_RETARD') return 'En retard';
      return 'En attente';
    }

    // ✅ Fix split sur DateTime — convertir en String d'abord
    String formatDate(dynamic date) {
      if (date == null) return '-';
      final str = date.toString();
      return str.length >= 10 ? str.substring(0, 10) : str;
    }

    final totalPaye = echeancier.mensualites
        .where((m) => m.statut == 'PAYEE')
        .fold(0.0, (sum, m) => sum + m.montant);
    final totalRestant = echeancier.montantTotal - totalPaye;
    final nbPayees =
        echeancier.mensualites.where((m) => m.statut == 'PAYEE').length;
    final progression = echeancier.mensualites.isEmpty
        ? 0.0
        : nbPayees / echeancier.mensualites.length;

    // ✅ Date du jour formatée correctement
    final today = DateTime.now();
    final dateGen =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: colorIndigo,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Echeancier de Paiement',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Reference #${echeancier.id}',
                    style: pw.TextStyle(
                      color: colorWhite70, // ✅ fix
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Statut: ${echeancier.statut}',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Genere le: $dateGen', // ✅ fix DateTime.split
                    style: pw.TextStyle(
                      color: colorWhite70, // ✅ fix
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Paiement Facilite App',
              style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            ),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            ),
          ],
        ),

        build: (context) => [

          pw.SizedBox(height: 20),

          // Infos client / prestataire
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: colorGrey,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CLIENT',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(nomClient,
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: colorGrey,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PRESTATAIRE',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(nomPrestataire,
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Résumé financier
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: colorIndigo),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem('Montant Total',
                        '${echeancier.montantTotal.toStringAsFixed(0)} DT',
                        colorIndigo),
                    _infoItem('Mensualites',
                        '${echeancier.nombreMensualites}',
                        colorIndigo),
                    _infoItem(
                        'Montant/Mois',
                        echeancier.mensualites.isNotEmpty
                            ? '${echeancier.mensualites[0].montant.toStringAsFixed(0)} DT'
                            : '-',
                        colorIndigo),
                    _infoItem('Date creation',
                        formatDate(echeancier.dateCreation), // ✅ fix
                        colorIndigo),
                  ],
                ),

                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 12),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem('Total Paye',
                        '${totalPaye.toStringAsFixed(0)} DT', colorGreen),
                    _infoItem('Restant',
                        '${totalRestant.toStringAsFixed(0)} DT', colorRed),
                    _infoItem('Payees',
                        '$nbPayees / ${echeancier.mensualites.length}',
                        colorGreen),
                    _infoItem('Progression',
                        '${(progression * 100).toStringAsFixed(0)}%',
                        colorOrange),
                  ],
                ),

                pw.SizedBox(height: 10),

                // ✅ Fix FractionallySizedBox — utiliser Stack + Positioned
                pw.Stack(
                  children: [
                    pw.Container(
                      height: 10,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                    ),
                    pw.Container(
                      height: 10,
                      width: (PdfPageFormat.a4.availableWidth - 96) * progression,
                      decoration: pw.BoxDecoration(
                        color: colorGreen,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Detail des Mensualites',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: colorIndigo,
            ),
          ),

          pw.SizedBox(height: 10),

          // Tableau mensualités
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: colorIndigo),
                children: [
                  _cellHeader('N'),
                  _cellHeader('Echeance'),
                  _cellHeader('Montant'),
                  _cellHeader('Statut'),
                  _cellHeader('Date Paiement'),
                ],
              ),
              ...echeancier.mensualites.map((m) {
                final bgColor = m.statut == 'PAYEE'
                    ? PdfColor.fromHex('#E8F5E9')
                    : m.statut == 'EN_RETARD'
                        ? PdfColor.fromHex('#FFEBEE')
                        : PdfColors.white;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bgColor),
                  children: [
                    _cell(m.numero.toString()),
                    _cell(formatDate(m.dateEcheance)),   // ✅ fix
                    _cell('${m.montant.toStringAsFixed(0)} DT'),
                    _cellStatut(statutLabel(m.statut), statutColor(m.statut)),
                    _cell(formatDate(m.datePaiement)),   // ✅ fix
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 30),

          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Signature Client',
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 30),
                  pw.Container(
                      width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text(nomClient,
                      style: pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Signature Prestataire',
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 30),
                  pw.Container(
                      width: 150, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Text(nomPrestataire,
                      style: pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'echeancier_${echeancier.id}.pdf',
    );
  }

  static pw.Widget _infoItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: color)),
      ],
    );
  }

  static pw.Widget _cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _cellStatut(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }
}