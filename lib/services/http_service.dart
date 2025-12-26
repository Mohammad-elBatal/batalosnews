import 'package:dio/dio.dart';
import '../models/app_config.dart';
import 'package:get_it/get_it.dart';

class HTTPService {
  final Dio dio = Dio();

  AppConfig? _appConfig;
  String? _news_base_url;
  String? _apiKey;

  HTTPService(){
    _appConfig = GetIt.instance.get<AppConfig>();
    _news_base_url = _appConfig!.NEWS_BASE_API_URL;
    _apiKey = _appConfig!.NEWS_API_KEY;
  }

  Future<Response?> get(
    String path, 
    String searchQuery, 
    String from, 
    String sources) async {
    try{
      String newsUrl = _news_base_url!;
      //https://pro-api.coingecko.com/api/v3
      if(path.isNotEmpty){
        newsUrl = "$_news_base_url$path";
      }
      return await dio.get(
        newsUrl,
        queryParameters: {
          'q': searchQuery,
          'from': from,
          'sources': sources,
          'apiKey': _apiKey,
        }
      );
    } catch (e) {
      print('HTTPService: Unable to perform GET request');
      print(e);
    }
    return null;
  }
}