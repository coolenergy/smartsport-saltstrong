import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsEvents {

  // name: 'screen_visit'
  //   parameters: {
  //     'screen_name': 'Name',
  //     'userId': userId,
  // }

  Future<void> sendAnalyticsEvent(String name, Map<String, dynamic>? params) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(name: name, parameters: params);
  }
}
