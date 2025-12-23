// ignore_for_file: use_build_context_synchronously

import 'package:batalosnews/classes/Article.dart';
import 'package:batalosnews/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/classes/DatabaseHelper.dart';
import 'dart:async';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() {
    return _HomepageState();
  }
}

class _HomepageState extends State<Homepage> {
  double? _deviceHeight, _deviceWidth;
  final NotificationServices _notificationService = NotificationServices();
  List<dynamic> articlesJson = [];
  List<Article> articles = [];
  List<Article> savedArticles = [];
  HTTPService? _http;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String from = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day - 7}";
  String searchQuery = "";
  String source = "bbc-news";
  String path = "everything";
  @override
  void initState() {
    super.initState();
    _http = GetIt.instance.get<HTTPService>();
    _dbHelper.database;
  }
  
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(207, 212, 216, 1),
      appBar: appBar(),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: _newsList(context),
          ),
        ],
      ),
    );  
  }
  AppBar appBar(){
    return AppBar(
      title: Text('Batalos News'),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Color.fromRGBO(35, 47, 63, 1),
    );
  }
  Widget _searchBar(){
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.01,
        horizontal: _deviceWidth! * 0.05,
      ),
      child: TextField(
        onSubmitted: (value){
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  Widget _newsList(BuildContext buildContext){
    return FutureBuilder(
      future: _refreshNews(buildContext)(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  articles = [];
                });
                  await _refreshNews(buildContext)();
                  await _loadSavedArticles(buildContext);
              },
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index){
                  return _newsListItem(index);
                },
              ),
            );
          } else {
            return const Center(
              child: Text('Unable to fetch news at the moment.'),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  Widget _newsListItem(int index){
    return Container(
      margin: EdgeInsets.symmetric(vertical: _deviceHeight! * 0.008, horizontal: _deviceWidth! * 0.02),
      decoration: BoxDecoration(
        color: Color.fromRGBO(35, 47, 63, 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
      children: [
        _newsListItemImage(index),
        _newsListItemText(index),
        _newsListItemPublishedAt(index)
      ],
    ));
  }
  Widget _newsListItemImage(int index){
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.network(
        articles[index].urlToImage ?? 'https://via.placeholder.com/150',
        fit: BoxFit.cover,
        width: double.infinity,
        height: _deviceHeight! * 0.22, // adjust to your layout
      ),
    );
  }
  Widget _newsListItemText(int index){
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.012,
        horizontal: _deviceWidth! * 0.03,
      ),
      child: Text(
        articles[index].title ?? 'No Description',
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
    );
  }
  Widget _newsListItemPublishedAt(int index){
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.012,
        horizontal: _deviceWidth! * 0.03,
      ),
      child: Text(
        DateFormat.yMMMMd().add_jm().format(articles[index].publishedAt!),
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.white,
        ),
      ),
    );
  }
  Future<bool> Function() _refreshNews(BuildContext buildContext){
    return () async {
      final response = await _http!.get(path, searchQuery, from, source);
      if (response != null) {
        articlesJson = response.data['articles'].where((article) => DateTime.now().subtract(const Duration(days: 1)).difference(DateTime.parse(article['publishedAt'])).inDays < 7).toList();
        articles = articlesJson.map((articleJson) => Article.fromJson(articleJson)).toList();
        _saveArticles();
        return true;
      }
      return false;
    };
  }
  Future<void> _saveArticles() async {
    if(articles.length == savedArticles.length) return;
    await _dbHelper.addArticles(articles);
  }
  Future<void> _loadSavedArticles(BuildContext buildContext) async {
    await _showNotification();
    final savedArticlesJson = await _dbHelper.getSavedArticles();
    setState(() {
      savedArticles = savedArticlesJson;
    });
    await _markArticlesAsOld();
  }
  Future<void> _markArticlesAsOld() async {
    await _dbHelper.setStatusAsOld();
  }
  //Future<void> _clearSavedArticles() async {
  //  await _dbHelper.deleteArticles();
  //}
  Future<void> _showToast(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    String message = "Total new articles: ${await _getNewsCount()}";
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  Future<void> _showNotification() async {
    int newArticlesCount = await _getNewsCount();
    _notificationService.initialize();
    if (newArticlesCount > 0){
    String message = "You Have New Articles";
    _notificationService.showNotification(
      title:"Batalos News",
      body: message,
    );
  }
  }
  Future<int> _getNewsCount() async {
    final count = await _dbHelper.getNewsCount();
    return count;
  }
}