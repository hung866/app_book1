import 'dart:convert';
import 'dart:html' as html; // 👈 Dành cho Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_summary.dart'; // 👈 File riêng để gọi Gemini AI

class Book1Screen extends StatefulWidget {
  const Book1Screen({super.key});

  @override
  State<Book1Screen> createState() => _Book1ScreenState();
}

class _Book1ScreenState extends State<Book1Screen> {
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String _audioUrl = "";

  final String textToRead = '''
Tôi tên là Dế Mèn. Thuở nhỏ, tôi sống vô tư lự trong một hang đất nhỏ.
Tôi thường trêu chọc các loài vật yếu hơn mình như chị Cào Cào, anh Bọ Ngựa.
Tôi nghĩ rằng mình là chúa tể của vùng đất ấy.
Nhưng chính vì kiêu căng, tôi đã mắc một sai lầm lớn.

Một hôm, tôi trêu chọc chị Cóc khiến chị nổi giận.
Chị Cóc đi trả thù Dế Choắt – người bạn hiền lành của tôi.
Từ đó, tôi vô cùng hối hận. Tôi nhận ra rằng, sống kiêu ngạo,
hống hách chỉ khiến người khác đau khổ và bản thân cũng chẳng vui vẻ gì.

Sau chuyện đó, tôi quyết định ra đi, bắt đầu cuộc phiêu lưu để chuộc lỗi
và học cách sống tốt đẹp hơn. Đó là khởi đầu cho hành trình phiêu lưu của đời tôi – Dế Mèn.
''';

  html.AudioElement? _audioElement;

  // 🎧 Gọi API Laravel → Laravel gọi FPT.AI
  Future<void> _startReading() async {
    setState(() {
      _isLoading = true;
      _isPlaying = false;
      _isPaused = false;
    });

    try {
      // 🔹 Gọi API Laravel trung gian (thay vì gọi FPT.AI trực tiếp)
      final url = Uri.parse("http://127.0.0.1:8000/api/tts");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": textToRead,
          "voice": "minhquang", // Laravel có thể dùng tham số này
          "speed": "0",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final audioUrl = data["audio_url"];

        if (audioUrl != null && audioUrl.toString().isNotEmpty) {
          setState(() => _audioUrl = audioUrl);

          // 🔊 Phát âm thanh
          _audioElement?.pause();
          _audioElement?.remove();

          _audioElement = html.AudioElement(audioUrl)
            ..autoplay = true
            ..controls = false;

          html.document.body!.append(_audioElement!);
          _audioElement!.play();

          // Khi đọc xong
          _audioElement!.onEnded.listen((_) {
            setState(() {
              _isPlaying = false;
              _isPaused = false;
            });
          });

          setState(() {
            _isPlaying = true;
            _isPaused = false;
          });
        } else {
          throw Exception("Không nhận được URL âm thanh hợp lệ từ server.");
        }
      } else {
        throw Exception(data["message"] ?? "Lỗi server Laravel");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi đọc truyện: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ⏸️ Tạm dừng đọc
  void _pauseReading() {
    if (_audioElement != null && _isPlaying) {
      _audioElement!.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    }
  }

  // ▶️ Tiếp tục đọc
  void _resumeReading() {
    if (_audioElement != null && _isPaused) {
      _audioElement!.play();
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  // 🧠 Tóm tắt nội dung bằng Gemini AI
  final _summarizer = GeminiSummarizer();
  String _summary = "";
  bool _isSummarizing = false;

  Future<void> _getSummary() async {
    setState(() => _isSummarizing = true);
    try {
      final result = await _summarizer.summarizeText(textToRead);
      setState(() => _summary = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tóm tắt: $e")),
      );
    } finally {
      setState(() => _isSummarizing = false);
    }
  }

  @override
  void dispose() {
    _audioElement?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dế Mèn phiêu lưu ký - Chương 1"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'lib/assets/anh1.jpg',
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  textToRead,
                  style: const TextStyle(fontSize: 18, height: 1.6),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🎛️ Các nút điều khiển đọc truyện
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startReading,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Đọc truyện"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _pauseReading : null,
                    icon: const Icon(Icons.pause),
                    label: const Text("Tạm dừng"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isPaused ? _resumeReading : null,
                    icon: const Icon(Icons.play_circle),
                    label: const Text("Tiếp tục"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // 🧠 Nút tóm tắt AI
            ElevatedButton.icon(
              onPressed: _isSummarizing ? null : _getSummary,
              icon: const Icon(Icons.smart_toy),
              label: Text(
                  _isSummarizing ? "Đang tóm tắt..." : "🧠 Tóm tắt bằng AI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),

            // 📝 Hiển thị phần tóm tắt
            if (_summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _summary,
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
