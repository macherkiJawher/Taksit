import '../core/constants/api_config.dart';
import '../core/storage/token_storage.dart';

class QrCodeApiService {
  static Future<String> getQrCodeUrl(int mensualiteId) async {
    final token = await TokenStorage.getToken();
    // Retourne l'URL complète avec token pour Image.network
    return "${ApiConfig.baseUrl.replaceAll('/api/auth', '')}"
        "/api/mensualites/$mensualiteId/qrcode?token=$token";
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {"Authorization": "Bearer $token"};
  }
}