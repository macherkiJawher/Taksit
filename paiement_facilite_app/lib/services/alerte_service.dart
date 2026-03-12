import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';
import 'notification_service.dart';

class AlerteService {

  static final baseUrl = "${ApiConfig.baseUrl}/alertes";

  // ✅ Récupérer toutes les alertes
  static Future<List<dynamic>> getMesAlertes() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse("$baseUrl/mes-alertes"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 Status alertes: ${response.statusCode}");
      debugPrint("📡 Body alertes: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("❌ Erreur getMesAlertes: $e");
    }
    return [];
  }

  static Future<void> verifierEtNotifier() async {
  try {
    final alertes = await getMesAlertes();

    for (int i = 0; i < alertes.length; i++) {
      final alerte = alertes[i];

      // ✅ Notification seulement pour les non lues
      if (alerte['lue'] == false) {
        await NotificationService.afficher(
          id: i,
          titre: alerte['titre'] ?? '',
          corps: alerte['message'] ?? '',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  } catch (e) {
    debugPrint("❌ Erreur verifierEtNotifier: $e");
  }
}

  // ✅ Marquer une alerte comme lue (appelé quand user ouvre le BottomSheet)
  static Future<void> marquerLue(int alerteId) async {
    try {
      final token = await TokenStorage.getToken();
      await http.put(
        Uri.parse("$baseUrl/$alerteId/lue"),
        headers: {"Authorization": "Bearer $token"},
      );
      debugPrint("✅ Alerte $alerteId marquée comme lue");
    } catch (e) {
      debugPrint("❌ Erreur marquerLue: $e");
    }
  }

  // ✅ Compter alertes non lues pour le badge
  static Future<int> getNombreNonLues() async {
  try {
    final token = await TokenStorage.getToken();
    if (token == null) return 0;

    final response = await http.get(
      Uri.parse("$baseUrl/count"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
  } catch (e) {
    debugPrint("❌ Erreur getNombreNonLues: $e");
  }
  return 0;
}
}