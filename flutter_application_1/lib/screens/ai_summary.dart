import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiSummarizer {
  // 🔑 Dán API Key thật của bạn tại đây
  final String apiKey = "AIzaSyB6vHSM4zuWo30igA4IMs3RlxGqdZOlYic";

  // ⚡ Model Gemini 2.5 Flash
  final String model = "gemini-2.5-flash";

  Future<String> summarizeText(String text) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
    );

    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Tóm tắt đoạn văn sau ngắn gọn, rõ ràng, dễ hiểu bằng tiếng Việt:\n$text"
            }
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      if (summary != null && summary.toString().isNotEmpty) {
        return summary.toString().trim();
      } else {
        throw Exception("Không tìm thấy nội dung tóm tắt trong phản hồi API.");
      }
    } else {
      throw Exception(
          "Lỗi API (${response.statusCode}): ${response.body.toString()}");
    }
  }
}