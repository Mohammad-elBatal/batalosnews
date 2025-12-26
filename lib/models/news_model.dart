import 'package:batalosnews/classes/Article.dart';
import 'package:batalosnews/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/classes/DatabaseHelper.dart';
import 'dart:async';

class NewsModel {
  final NotificationServices _notificationService = NotificationServices();
  HTTPService? _http;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  NewsModel() {
    _http = GetIt.instance.get<HTTPService>();
    _dbHelper.database;
  }

  Future<void> Function() refreshNews(String path, String searchQuery, String from, String source) {
    return () async {
      final response = await _http!.get(path, searchQuery, from, source);
      if (response != null) {
        List<dynamic> articlesJson = response.data['articles'].where((article) => DateTime.now().subtract(const Duration(days: 1)).difference(DateTime.parse(article['publishedAt'])).inDays < 7).toList();
        List<Article> articles = articlesJson.map((articleJson) => Article.fromJson(articleJson)).toList();
        saveArticles(articles);
      }
    };
  }
  Future<void> saveArticles(List<Article> articles) async {
    await _dbHelper.addArticles(articles);
  }
  Future<List<Article>> loadSavedArticles() async {
    final savedArticlesJson = await _dbHelper.getSavedArticles();
    await markArticlesAsOld();
    return savedArticlesJson;
  }
  Future<void> markArticlesAsOld() async {
    await _dbHelper.setStatusAsOld();
  }
  Future<void> showToast(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    String message = "Total new articles: ${await getNewsCount()}";
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  Future<void> showNewArticlesNotification(String path, String searchQuery, String from, String source) async {
    //await refreshNews(path, searchQuery, from, source)();
    //int newArticlesCount = await getNewsCount();
    //_notificationService.initialize();
    //if (newArticlesCount > 0){
    String message = "You Have New Articles";
    _notificationService.showNotification(
      title:"Batalos News",
      body: message,
    );
  //}
  }
  Future<int> getNewsCount() async {
    final count = await _dbHelper.getNewsCount();
    return count;
  }
}