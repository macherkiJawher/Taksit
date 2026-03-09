import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';

class AuthService {

  // 🔐 LOGIN
  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "motDePasse": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = AuthResponse.fromJson(jsonDecode(response.body));

      await TokenStorage.save(
        token: data.token,
        role: data.role,
        userId: data.id,
      );

      return data;

    } else if (response.statusCode == 403) {
      // ✅ Compte désactivé
      final body = jsonDecode(response.body);
      throw Exception(
        body['error'] ?? "⛔ Compte désactivé. Contactez l'administrateur."
      );

    } else {
      throw Exception("Email ou mot de passe incorrect");
    }
  }

  // 📝 REGISTER
  static Future<String> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['message'];
    } else {
      throw Exception("Erreur lors de l'inscription");
    }
  }

  // 🚪 LOGOUT
  static Future<void> logout() async {
    await TokenStorage.clear();
  }
}