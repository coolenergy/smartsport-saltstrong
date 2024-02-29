import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';

class TidesAndFeedingResponse {
  final List<TidePeriod> tidePeriods;
  final List<FeedingActivityArr> feedingActivityArr;
  final List<ForecastOfTheDay> forecastOfTheDay;
  final WeatherSummary summary;
  const TidesAndFeedingResponse({
    required this.tidePeriods,
    required this.feedingActivityArr,
    required this.summary,
    required this.forecastOfTheDay,
  });

  factory TidesAndFeedingResponse.fromMap(Map<String, dynamic> map) {
    return TidesAndFeedingResponse(
      tidePeriods: map["tidesOfTheDay"]["tidePeriods"].map<TidePeriod>((x) => TidePeriod.fromMap(x)).toList(),
      feedingActivityArr: map["feedingOfTheDay"]["feedingActivityArr"]
          .map<FeedingActivityArr>((x) => FeedingActivityArr.fromMap(x))
          .toList(),
      summary: WeatherSummary.fromMap(map["summary"]),
      forecastOfTheDay:
          map["feedingOfTheDay"]["forecastOfTheDay"].map<ForecastOfTheDay>((x) => ForecastOfTheDay.fromMap(x)).toList(),
    );
  }
}

class WeatherSummary {
  final String longMET;
  final String long;

  factory WeatherSummary.fromMap(Map<String, dynamic> map) {
    if (map["success"].toString() != "true") {
      return WeatherSummary(
        long: "No weather data available",
        longMET: "No weather data available",
      );
    }

    Map phrases = map["response"][0]["phrases"];
    return WeatherSummary(
      long: phrases['long'],
      longMET: phrases['longMET'],
    );
  }

  const WeatherSummary({
    required this.longMET,
    required this.long,
  });
}

class DailyForecast {
  final String shortWeather;
  final String dayIcon;
  final DateTime sunRise;
  final DateTime sunSet;
  final String weatherSummary;
  final int windSpeedMinMph;
  final int windSpeedMaxMph;
  final int windGustMph;
  final int tempMinF;
  final int tempMaxF;
  final String moonNamePhase;
  final String moonIcon;
  final DateTime? moonRise;
  final DateTime? moonSet;

  const DailyForecast({
    required this.shortWeather,
    required this.dayIcon,
    required this.sunRise,
    required this.sunSet,
    required this.weatherSummary,
    required this.windSpeedMinMph,
    required this.windSpeedMaxMph,
    required this.windGustMph,
    required this.tempMinF,
    required this.tempMaxF,
    required this.moonNamePhase,
    required this.moonIcon,
    required this.moonRise,
    required this.moonSet,
  });
}
