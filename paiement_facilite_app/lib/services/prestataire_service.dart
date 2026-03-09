import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paiement_facilite_app/models/prestataire_stats.dart';
import '../core/storage/token_storage.dart';
import '../models/prestataire.dart';

class PrestataireService {
    static const baseUrl = "http://10.0.2.2:8080/api";


  static Future<Prestataire> getMe() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/prestataires/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return Prestataire.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Impossible de récupérer le prestataire");
    }
  }

   static Future<PrestataireStats> getStats(int prestataireId) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/prestataires/$prestataireId/stats"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return PrestataireStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Impossible de récupérer les statistiques");
    }
  }
}
