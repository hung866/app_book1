import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final String language;

  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(String) onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.language,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          language == "Tiếng Việt" ? "⚙️ Cài đặt" : "⚙️ Settings",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // PROFILE
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(language == "Tiếng Việt" ? "Thông tin cá nhân" : "Profile",
                  style: TextStyle(fontSize: fontSize)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),

          // NGÔN NGỮ
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.teal),
              title: Text(language == "Tiếng Việt" ? "Ngôn ngữ" : "Language",
                  style: TextStyle(fontSize: fontSize)),
              trailing: Text(language,
                  style: TextStyle(color: Colors.grey[600], fontSize: fontSize * 0.9)),
              onTap: () => _showLanguageDialog(context),
            ),
          ),

          // MÀU NỀN
          Card(
            child: SwitchListTile(
              value: isDarkMode,
              activeColor: Colors.teal,
              title: Text(language == "Tiếng Việt" ? "Chế độ tối" : "Dark Mode",
                  style: TextStyle(fontSize: fontSize)),
              secondary: const Icon(Icons.brightness_6, color: Colors.teal),
              onChanged: (value) => onThemeChanged(value),
            ),
          ),

          // CỠ CHỮ
          Card(
            child: ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.teal),
              title: Text(language == "Tiếng Việt" ? "Cỡ chữ" : "Font size",
                  style: TextStyle(fontSize: fontSize)),
              trailing: Text("${fontSize.toInt()}",
                  style: TextStyle(color: Colors.grey[600], fontSize: fontSize * 0.9)),
              onTap: () => _showFontSizeDialog(context),
            ),
          ),

          const SizedBox(height: 20),

          // Đăng nhập / Đăng ký
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.login, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                label: Text(language == "Tiếng Việt" ? "Đăng nhập" : "Login",
                    style: TextStyle(fontSize: fontSize * 0.9)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.app_registration, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                label: Text(language == "Tiếng Việt" ? "Đăng ký" : "Register",
                    style: TextStyle(fontSize: fontSize * 0.9)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(language == "Tiếng Việt" ? "🌐 Chọn ngôn ngữ" : "🌐 Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text("Tiếng Việt"),
                value: "Tiếng Việt",
                groupValue: language,
                onChanged: (value) {
                  onLanguageChanged(value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text("English"),
                value: "English",
                groupValue: language,
                onChanged: (value) {
                  onLanguageChanged(value.toString());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    double tempFontSize = fontSize;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(language == "Tiếng Việt" ? "✏️ Chỉnh cỡ chữ" : "✏️ Change font size"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: tempFontSize,
                    min: 12,
                    max: 30,
                    divisions: 18,
                    label: tempFontSize.toInt().toString(),
                    onChanged: (value) {
                      setStateDialog(() {
                        tempFontSize = value;
                      });
                    },
                  ),
                  Text(
                      "${language == "Tiếng Việt" ? "Cỡ chữ" : "Font size"}: ${tempFontSize.toInt()}"),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                onFontSizeChanged(tempFontSize);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
