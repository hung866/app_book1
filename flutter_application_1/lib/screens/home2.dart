import 'package:flutter/material.dart';
import 'book1.dart'; 
import 'book2.dart'; 
import 'book3.dart'; 
import 'book4.dart'; 

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final String language;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          language == "Tiếng Việt"
              ? "ỨNG DỤNG ĐỌC SÁCH TỰ ĐỘNG"
              : "AUTO READING APP",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    language == "Tiếng Việt" ? "ĐỀ XUẤT" : "SUGGESTION",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.all(12),
              children: [
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Book1Screen()),
                    );
                  },
                  child: _buildBookCard("Dế Mèn Phiêu Lưu Ký", "lib/assets/anh1.jpg"),
                ),

                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Book2Screen()),
                    );
                  },
                  child: _buildBookCard("Cây Khế", "lib/assets/anh2.jpg"),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Book3Screen()),
                    );
                  },
                  child: _buildBookCard("Tấm Cám", "lib/assets/anh3.jpg"),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Book4Screen()),
                    );
                  },
                  child: _buildBookCard("Thạch Sanh", "lib/assets/anh4.jpg"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildBookCard(String title, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}