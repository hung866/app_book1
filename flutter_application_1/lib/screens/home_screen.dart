import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final String language;

  const Home({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // ✅ đổi nền
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
            // ĐỀ XUẤT
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

            // Lưới hiển thị sách
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.all(12),
              children: [
                _buildBookItem(context, "Sách 1", "lib/assets/anh1.jpg"),
                _buildBookItem(context, "Sách 2", "lib/assets/anh1.jpg"),
                _buildBookItem(context, "Sách 3", "lib/assets/anh1.jpg"),
                _buildBookItem(context, "Sách 4", "lib/assets/anh1.jpg"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo item sách
  Widget _buildBookItem(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Khi nhấn vào sách
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookDetailScreen(title: title, image: imagePath),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}

// Màn hình chi tiết sách
class BookDetailScreen extends StatelessWidget {
  final String title;
  final String image;

  const BookDetailScreen({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          children: [
            Image.asset(image),
            const SizedBox(height: 20),
            Text("📖 Nội dung của $title sẽ hiển thị ở đây"),
          ],
        ),
      ),
    );
  }
}
