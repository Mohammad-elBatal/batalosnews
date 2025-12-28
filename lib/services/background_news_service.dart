import 'package:batalosnews/services/notification_services.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/classes/DatabaseHelper.dart';

class BackgroundNewsService {
  Future<void> checkAndNotify() async {
    final http = HTTPService();
    final db = DatabaseHelper.instance;

    final response = await http.get(
      "everything",
      "",
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
      "bbc-news",
    );

    if (response == null) return;
    final articles = response.data['articles'];
    await db.addArticlesFromJson(articles);

    final count = await db.getNewsCount();

    if (count > 0) {
      final notificationService = NotificationServices();
      await notificationService.initialize();

      await notificationService.showNotification(
        title: "Batalos News",
        body: "You have $count new articles",
      );
    }
  }
}
