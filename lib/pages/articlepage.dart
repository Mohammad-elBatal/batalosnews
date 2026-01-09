import 'package:flutter/material.dart';

class ArticlePage extends StatelessWidget {
  final String title;
  final String content;
  final String? urlToImage;
  final String date;

  const ArticlePage({super.key, required this.title, required this.content, this.urlToImage, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(207, 212, 216, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(35, 47, 63, 1),
        titleTextStyle: TextStyle(color: Colors.white),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (urlToImage != null)
              Image.network(urlToImage!, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(date),
            Text(content),
          ],
        ),
      ),
    );
  }
}