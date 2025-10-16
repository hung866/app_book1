import 'dart:convert';
import 'package:http/http.dart' as http;

class TTSService {
  static const String apiUrl = "http://127.0.0.1:8000/api/tts";

  static Future<String?> callLaravelTTS(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["audioUrl"];
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Lỗi kết nối API: $e");
      return null;
    }
  }
}
