import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  html.AudioElement? _audioElement;
  bool _isPlaying = false; // ✅ trạng thái đang phát
  bool _isPaused = false; // ✅ trạng thái đã dừng

  // 🗣️ Gọi Laravel để chuyển văn bản sang giọng nói
  Future<void> callLaravelTTS(String text) async {
    const String apiUrl = 'http://127.0.0.1:8000/api/tts';

    setState(() {
      _isLoading = true;
      _isPlaying = false;
      _isPaused = false;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': 'thuminh',
          'speed': '0',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['async'] ?? data['audio_url'];

        if (audioUrl != null && audioUrl.toString().isNotEmpty) {
          print("🔊 File âm thanh: $audioUrl");

          // Dừng âm thanh cũ (nếu có)
          _audioElement?.pause();
          _audioElement?.remove();

          // Tạo phần tử âm thanh mới
          _audioElement = html.AudioElement(audioUrl)
            ..autoplay = true
            ..controls = false
            ..onPlay.listen((_) {
              setState(() {
                _isPlaying = true;
                _isPaused = false;
              });
            })
            ..onPause.listen((_) {
              setState(() {
                _isPlaying = false;
                _isPaused = true;
              });
            })
            ..onEnded.listen((_) {
              setState(() {
                _isPlaying = false;
                _isPaused = false;
              });
            });

          html.document.body!.append(_audioElement!);
        } else {
          throw Exception("Không có URL âm thanh hợp lệ từ server");
        }
      } else {
        print("❌ Lỗi server: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi gọi API TTS")),
        );
      }
    } catch (e) {
      print("🔥 Lỗi kết nối: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kết nối đến server")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🤖 Gọi Laravel để tóm tắt nội dung bằng Gemini
  Future<void> callLaravelSummary(String text) async {
    const String apiUrl = 'http://127.0.0.1:8000/api/summarize';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['summary'] ?? "Không có tóm tắt";

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("📘 Tóm tắt nội dung"),
            content: Text(summary),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đóng"),
              ),
            ],
          ),
        );
      } else {
        print("❌ Lỗi khi tóm tắt: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi gọi API tóm tắt")),
        );
      }
    } catch (e) {
      print("🔥 Lỗi kết nối đến Laravel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kết nối đến server")),
      );
    }
  }

  // ⏸️ Dừng đọc
  void pauseAudio() {
    if (_audioElement != null && _isPlaying) {
      _audioElement!.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    }
  }

  // ▶️ Tiếp tục đọc
  void resumeAudio() {
    if (_audioElement != null && _isPaused) {
      _audioElement!.play();
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
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
      // 🔙 Nút back → quay về Home (home2)
      appBar: AppBar(
        title: const Text("AI Tóm tắt & Giọng nói 📖"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/home");
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Nhập nội dung sách hoặc đoạn văn cần xử lý...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔊 Nút đọc nội dung
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        callLaravelTTS(text);
                      }
                    },
              icon: const Icon(Icons.volume_up),
              label: _isLoading
                  ? const Text("Đang xử lý giọng nói...")
                  : const Text("Đọc nội dung 🔊"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            // ⏸️ Nút Dừng đọc
            if (_isPlaying)
              ElevatedButton.icon(
                onPressed: pauseAudio,
                icon: const Icon(Icons.pause_circle_filled),
                label: const Text("Dừng đọc ⏸️"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

            // ▶️ Nút Tiếp tục đọc
            if (_isPaused)
              ElevatedButton.icon(
                onPressed: resumeAudio,
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Tiếp tục đọc ▶️"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 12),

            // 🤖 Nút tóm tắt AI
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        callLaravelSummary(text);
                      }
                    },
              icon: const Icon(Icons.text_snippet),
              label: const Text("Tóm tắt bằng AI 🤖"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
