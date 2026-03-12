import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';

class AdminService {
  static final baseUrl = "${ApiConfig.baseUrl}/admin";

  static Future<Map<String, dynamic>> getStats() async {
    final token = await TokenStorage.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/stats"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Erreur stats");
  }

  static Future<List<dynamic>> getUtilisateurs() async {
    final token = await TokenStorage.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/utilisateurs"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Erreur utilisateurs");
  }

  static Future<bool> toggleActif(int userId) async {
    final token = await TokenStorage.getToken();
    final res = await http.put(
      Uri.parse("$baseUrl/utilisateurs/$userId/toggle"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['actif'];
    }
    throw Exception("Erreur toggle");
  }

  static Future<List<dynamic>> getEcheanciers() async {
    final token = await TokenStorage.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/echeanciers"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Erreur écheanciers");
  }

  static Future<List<dynamic>> getStatsParMois() async {
    final token = await TokenStorage.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/stats/par-mois"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Erreur stats par mois");
  }
}