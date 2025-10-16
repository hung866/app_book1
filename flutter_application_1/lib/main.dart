import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home2.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/create_book.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const MyApp(),
    ),
  );
}

class AppSettings extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16;
  String _language = "Tiếng Việt";

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  String get language => _language;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: settings.fontSize / 16,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: "/home",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/edit-profile": (context) => const EditProfileScreen(
              currentUsername: "",
              currentEmail: "",
            ),
        "/change-password": (context) => const ChangePasswordScreen(),
        "/home": (context) => const HomeShell(),
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    
    final List<Widget> _pages = [
      HomeScreen(
        isDarkMode: settings.isDarkMode,
        fontSize: settings.fontSize,
        language: settings.language,
      ),
      const CreateBookScreen(), 
      SettingsScreen(
        isDarkMode: settings.isDarkMode,
        fontSize: settings.fontSize,
        language: settings.language,
        onThemeChanged: (v) => settings.setDarkMode(v),
        onFontSizeChanged: (v) => settings.setFontSize(v),
        onLanguageChanged: (v) => settings.setLanguage(v),
      ),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "TRANG CHỦ"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "THÊM SÁCH"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "CÀI ĐẶT"),
        ],
      ),
    );
  }
}
