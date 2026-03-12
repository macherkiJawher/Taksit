import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';
import '../models/client.dart';

class ClientService {
  static final baseUrl = "${ApiConfig.baseUrl}/clients";

  static Future<List<Client>> searchByName(String nom) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/search?nom=$nom"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Client.fromJson(e)).toList();
    } else {
      throw Exception("Erreur recherche client");
    }
  }
  static Future<double> getScoreByName(String nom) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/score-by-name?nom=$nom"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception("Client non trouvé");
    }
  }

// lib/services/client_service.dart


  static final baseUrl1 = ApiConfig.baseUrl;

  // 🔍 Rechercher clients par nom (pour prestataire)
  
  // 📊 Score d'éligibilité par nom
 

  // 📊 Score par ID
  static Future<double> getScoreById(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl1/clients/$id/score"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as num).toDouble();
    } else {
      throw Exception("Erreur score");
    }
  }

  // 👤 Récupérer profil client par ID
  static Future<Map<String, dynamic>> getById(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl1/clients/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Client non trouvé");
    }
  }
}