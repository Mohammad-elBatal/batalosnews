import 'package:batalosnews/services/notification_services.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/classes/DatabaseHelper.dart';
import 'package:get_it/get_it.dart';

class BackgroundNewsService {
  Future<void> checkAndNotify() async {
    final http = GetIt.instance.get<HTTPService>();
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
      await notificationService.initialize(isBackground: true);
      await notificationService.showNotification(
        title: "Batalos News",
        body: "You have new articles",
      );
    }
  }
}
