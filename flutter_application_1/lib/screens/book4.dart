import 'dart:convert';
import 'dart:html' as html; // 👈 dùng cho Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_summary.dart'; // 👈 File riêng để gọi Gemini AI

class Book4Screen extends StatefulWidget {
  const Book4Screen({super.key});

  @override
  State<Book4Screen> createState() => _Book4ScreenState();
}

class _Book4ScreenState extends State<Book4Screen> {
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String _audioUrl = "";

  // ✅ FPT.AI API Key & Voice
  final String apiKey = "fFO05oCcIcZW564ahRDy0zjgdGxJVzM2";
  final String voice = "minhquang";

  final String textToRead = '''
Ngày xưa, có hai vợ chồng già hiền lành sống trong một túp lều nhỏ. Họ không có con cái nên rất buồn. Một ngày nọ, Bà lão nằm mơ thấy Bụt bảo rằng: "Trời sẽ ban cho hai ông bà một đứa con trai". Ít lâu sau, bà sinh ra một cậu bé khỏe mạnh, đặt tên là Thạch Sanh.

Khi cha mẹ mất, Thạch Sanh sống một mình dưới gốc đa, lấy nghề săn bắn làm kế sinh nhai. Nhờ tập luyện, chàng có sức mạnh phi thường. Một hôm, Lý Thông đi qua thấy Thạch Sanh khỏe mạnh liền nghĩ cách lợi dụng. Hắn rủ Thạch Sanh về ở chung, giả làm anh em kết nghĩa.

Một ngày nọ, đến lượt Lý Thông canh miếu, nơi có con chằn tinh ăn thịt người. Hắn lừa Thạch Sanh đi thay. Nhưng với cung tên và sức mạnh, Thạch Sanh đã giết được chằn tinh. Lý Thông cướp công, đem đầu chằn tinh dâng vua. Vua ban thưởng, còn Thạch Sanh bị lừa phải trốn về gốc đa.

Sau đó, công chúa bị đại bàng bắt. Thạch Sanh bắn gãy cánh đại bàng, lần theo dấu đến hang cứu công chúa. Nhưng khi ra ngoài, Lý Thông lại lấp cửa hang, hòng chôn sống Thạch Sanh trong đó. Nhờ cây đàn thần mà Thạch Sanh tìm được trong hang, chàng thoát ra ngoài.

Khi công chúa trở về cung nhưng câm lặng không nói được. Một lần, nghe tiếng đàn của Thạch Sanh, nàng tỉnh lại và kể hết mọi chuyện. Vua tức giận, bắt Lý Thông mẹ con tội ác. Nhưng Thạch Sanh khoan dung, tha cho họ về. Trên đường về, trời giáng sét đánh chết mẹ con Lý Thông.

Vua gả công chúa cho Thạch Sanh. Lúc bấy giờ, các nước chư hầu đem quân sang xâm lược. Thạch Sanh một mình ra trận, dùng tiếng đàn thần khiến quân địch khiếp sợ phải đầu hàng. Sau đó, Thạch Sanh sống hạnh phúc bên công chúa, nhân dân yên vui, đất nước thái bình.
''';

  html.AudioElement? _audioElement;

  // 🔊 Đọc truyện bằng FPT.AI, xử lý lỗi 429
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

      http.Response response;
      int retry = 0;

      // ✅ Nếu bị lỗi 429 thì đợi rồi thử lại
      do {
        response = await http.post(url, headers: headers, body: textToRead);
        if (response.statusCode == 429) {
          retry++;
          if (retry > 3) throw Exception("FPT.AI quá tải, vui lòng thử lại sau vài phút.");
          await Future.delayed(const Duration(seconds: 3));
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
        title: const Text("Thạch Sanh"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'lib/assets/anh4.jpg',
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
