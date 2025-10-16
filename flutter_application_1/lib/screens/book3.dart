import 'dart:convert';
import 'dart:html' as html; // 👈 Dành cho Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_summary.dart'; // 👈 Gọi Google Gemini AI

class Book3Screen extends StatefulWidget {
  const Book3Screen({super.key});

  @override
  State<Book3Screen> createState() => _Book3ScreenState();
}

class _Book3ScreenState extends State<Book3Screen> {
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String _audioUrl = "";

  // ✅ FPT.AI API Key mới & Voice
  final String apiKey = "fFO05oCcIcZW564ahRDy0zjgdGxJVzM2";
  final String voice = "minhquang";

  final String textToRead = '''
Ngày xửa ngày xưa, có hai chị em cùng cha khác mẹ là Tấm và Cám. 
Mẹ Tấm mất sớm, cha Tấm lấy vợ khác, sinh ra Cám. 
Sau khi cha Tấm mất, dì ghẻ và Cám đối xử với Tấm rất tệ, bắt Tấm làm hết việc nặng nhọc trong nhà.

Một hôm, dì ghẻ bảo hai chị em ra đồng xúc tép, ai được nhiều hơn sẽ thưởng cho một chiếc yếm đỏ. 
Tấm chăm chỉ nên xúc được nhiều, còn Cám thì lười biếng, mải chơi. 
Cám lừa Tấm xuống ao tắm rồi trút hết tép của Tấm mang về nhà. 
Tấm chỉ còn lại một con cá bống nhỏ, cô nuôi nó mỗi ngày. 
Nhưng khi dì ghẻ biết chuyện, bà ta bắt Cám giết bống ăn thịt. 
Tấm đau khổ khóc, được Bụt hiện lên bảo mang xương bống chôn xuống bốn góc giường để được giúp đỡ.

Nhờ phép màu, Tấm được chim sẻ giúp đỡ chọn thóc, có quần áo đẹp đi hội, và gặp nhà vua. 
Nhà vua thương yêu Tấm và lấy cô làm hoàng hậu. 
Dì ghẻ và Cám ghen tức, lập mưu hại chết Tấm nhiều lần, nhưng Tấm nhờ Bụt hóa thân thành chim vàng anh, cây xoan đào, quả thị... 
Cuối cùng, Tấm sống lại, trừng phạt Cám và dì ghẻ, và sống hạnh phúc mãi mãi bên nhà vua.
''';

  html.AudioElement? _audioElement;

  // 🎧 Đọc truyện bằng FPT.AI TTS
  Future<void> _startReading() async {
    setState(() {
      _isLoading = true;
      _isPlaying = false;
      _isPaused = false;
    });

    try {
      final url = Uri.parse("https://api.fpt.ai/hmi/tts/v5");
      final headers = {
        "api-key": apiKey,
        "speed": "0",
        "voice": voice,
      };

      // ✅ Gọi API, retry nếu bị 429
      http.Response response;
      int retry = 0;
      do {
        response = await http.post(url, headers: headers, body: textToRead);
        if (response.statusCode == 429) {
          retry++;
          if (retry > 3) throw Exception("Gọi API quá nhiều lần, hãy thử lại sau ít phút.");
          await Future.delayed(const Duration(seconds: 3)); // ⏳ chờ rồi thử lại
        } else {
          break;
        }
      } while (true);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audioUrl = data["async"];

        if (audioUrl != null && audioUrl.toString().isNotEmpty) {
          setState(() => _audioUrl = audioUrl);

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
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đọc truyện: $e")),
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

  // 🧠 Tóm tắt bằng AI Gemini
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
        title: const Text("Tấm Cám"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'lib/assets/anh3.jpg',
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

            // 🧠 Nút tóm tắt bằng AI
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
