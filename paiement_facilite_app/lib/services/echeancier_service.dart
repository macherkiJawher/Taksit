import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';
import '../models/echeancier.dart';

class EcheancierService {
  static final baseUrl = "${ApiConfig.baseUrl}/echeanciers";

  // 🔹 Créer un échéancier
 static Future<Echeancier> creer({
  required String nomClient,
  required double montant,
  required int nbMensualites,
}) async {

  final token = await TokenStorage.getToken();

  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "nomClient": nomClient, // 🔥
      "montantTotal": montant,
      "nombreMensualites": nbMensualites,
    }),
  );

  if (response.statusCode == 200) {
    return Echeancier.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Erreur création échéancier");
  }
}


  // 🔹 Récupérer un échéancier par ID
  static Future<Echeancier> getById(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return Echeancier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Échéancier introuvable");
    }
  }

  // 🔹 Récupérer tous les échéanciers du prestataire
  static Future<List<Echeancier>> getAllPrestataire() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Echeancier.fromJson(json)).toList();
    } else {
      throw Exception("Impossible de récupérer les échéanciers");
    }
  }

  static Future<List<Echeancier>> searchByClientName(String nom) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/search?nom=$nom"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Echeancier.fromJson(e)).toList();
    } else {
      throw Exception("Erreur recherche échéanciers");
    }
  }

  // 🔹 Récupérer les échéanciers d'un CLIENT spécifique
  static Future<List<Echeancier>> getByClientId(int clientId) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/echeanciers/client/$clientId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Echeancier.fromJson(json)).toList();
    } else {
      throw Exception("Impossible de récupérer les échéanciers du client");
    }
  }

}
