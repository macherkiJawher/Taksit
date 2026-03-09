import 'package:http/http.dart' as http;
import '../core/storage/token_storage.dart';

class ApiService {

  static Future<http.Response> get(String url) async {
    final token = await TokenStorage.getToken();

    return http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }
}
