import 'dart:convert';
import 'dart:html' as html; // 👈 Dành cho Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_summary.dart'; // 👈 File riêng để gọi Gemini AI

class Book2Screen extends StatefulWidget {
  const Book2Screen({super.key});

  @override
  State<Book2Screen> createState() => _Book2ScreenState();
}

class _Book2ScreenState extends State<Book2Screen> {
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String _audioUrl = "";

  final String textToRead = '''
Ngày xưa có hai anh em nhà kia, cha mẹ mất sớm để lại cho họ một gia tài. 
Người anh tham lam chiếm hết nhà cửa, ruộng vườn, chỉ để lại cho em trai 
một túp lều nhỏ và một cây khế.

Người em hiền lành chăm sóc cây khế ngày đêm. Một năm kia, cây ra rất nhiều quả. 
Bỗng một hôm, có con chim lạ bay tới ăn khế. Người em than: 
"Chim ơi, khế là của tôi, chim ăn thì tôi lấy gì mà sống?"

Chim nói: "Ăn một quả, trả cục vàng. May túi ba gang, mang đi mà đựng."

Người em làm theo lời chim. Hôm sau chim đến chở người em đi qua biển, 
đến đảo có rất nhiều vàng bạc châu báu. Người em chỉ lấy đầy túi ba gang 
rồi quay về. Từ đó, cuộc sống của vợ chồng người em trở nên ấm no, hạnh phúc.

Người anh biết chuyện, liền xin đổi tài sản để lấy cây khế. 
Khi chim đến, người anh cũng bắt chước em nói câu: 
"Ăn một quả, trả cục vàng. May túi mười hai gang, mang đi mà đựng."

Chim vẫn đưa người anh đi, nhưng vì túi quá to, 
vàng nặng khiến người anh rơi xuống biển và không bao giờ trở về nữa.
''';

  html.AudioElement? _audioElement;

  // 🎧 Gọi API TTS qua Laravel server (tránh lỗi 429 & ẩn key)
  Future<void> _startReading() async {
    setState(() {
      _isLoading = true;
      _isPlaying = false;
      _isPaused = false;
    });

    try {
      final url = Uri.parse("http://127.0.0.1:8000/api/tts"); // 🔹 Laravel endpoint

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": textToRead,
          "voice": "minhquang",
          "speed": "0",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final audioUrl = data["audio_url"];
        if (audioUrl != null && audioUrl.toString().isNotEmpty) {
          setState(() => _audioUrl = audioUrl);

          _audioElement?.pause();
          _audioElement?.remove();

          _audioElement = html.AudioElement(audioUrl)
            ..autoplay = true
            ..controls = false;

          html.document.body!.append(_audioElement!);
          _audioElement!.play();

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
          throw Exception("Không nhận được URL âm thanh hợp lệ.");
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi khi tóm tắt: $e")));
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
        title: const Text("Sự tích cây khế"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'lib/assets/anh2.jpg',
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

            // 🎛️ Nút điều khiển đọc truyện
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _pauseReading : null,
                    icon: const Icon(Icons.pause),
                    label: const Text("Tạm dừng"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isPaused ? _resumeReading : null,
                    icon: const Icon(Icons.play_circle),
                    label: const Text("Tiếp tục"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // 🧠 Nút tóm tắt
            ElevatedButton.icon(
              onPressed: _isSummarizing ? null : _getSummary,
              icon: const Icon(Icons.smart_toy),
              label: Text(_isSummarizing ? "Đang tóm tắt..." : "🧠 Tóm tắt bằng AI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),

            // 📝 Hiển thị tóm tắt
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
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
