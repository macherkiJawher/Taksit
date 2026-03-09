import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../core/storage/token_storage.dart';

class MensualiteService {
  static const baseUrl = "http://10.0.2.2:8080/api/mensualites";

  // ✅ Payer sans photo (existant)
  static Future<void> payer(int mensualiteId) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/$mensualiteId/payer"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Paiement échoué");
    }
  }

  // ✅ Payer avec photo du reçu (nouveau)
  static Future<void> payerAvecRecu({
    required int mensualiteId,
    required String imagePath,
  }) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse("$baseUrl/$mensualiteId/payer-avec-recu"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Paiement avec reçu échoué");
    }
  }
}