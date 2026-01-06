import 'package:batalosnews/services/notification_services.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/classes/DatabaseHelper.dart';
import 'package:get_it/get_it.dart';

class BackgroundNewsService {
  Future<void> checkAndNotify() async {
    //print("📡 Background Service Started");
    
    final http = GetIt.instance.get<HTTPService>();
    final db = DatabaseHelper.instance;

    try {
      final response = await http.get(
        "everything",
        "",
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day - 1}",
        "bbc-news",
      );

      if (response == null || response.data == null) {
        //print("API returned null or empty data");
        return;
      }

      final articles = response.data['articles'];
      //print("Fetched ${articles.length} articles. Saving to DB...");
      
      await db.addArticlesFromJson(articles);
      
      final count = await db.getNewsCount();
      //print("Current DB Count: $count");

      if (count > 0) {
        final notificationService = NotificationServices();
        await notificationService.initialize(isBackground: true);
        await notificationService.showNotification(
          title: "Batalos News",
          body: "You have new articles",
        );
      }
    } catch (e) {
      //print("Error in checkAndNotify: $e");
    }
  }
}
