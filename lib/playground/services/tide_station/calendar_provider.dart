import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/helpers/keep_alive_provider.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/get_tides_and_feeding_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/tide_station.dart';
import 'package:salt_strong_poc/playground/services/http/http_service.dart';
import 'package:salt_strong_poc/playground/services/markers/customized_providers.dart';

final strikeScoreProvider = FutureProvider.autoDispose<DailyStrikeScoreResponse>((ref) async {
  final closestStation = await ref.watch(closestStationProvider.future);

  if (closestStation == null) {
    throw NoNearbyTideStationException();
  }

  final dioService = ref.read(httpServiceProvider);
  final token = ref.refresh(httpCancelTokenProvider('strikeScore'));

  final strikeScore = await dioService.request(GetDailyStrikeScoreRequest(closestStation!), converter: (resp) {
    return DailyStrikeScoreResponse.fromMap(resp);
  }, cancelToken: token);
  return strikeScore;
});

final tidesAndFeedingProvider =
    FutureProvider.family.autoDispose<TidesAndFeedingResponse, TidesDaySpec>((ref, arg) async {
  // print(arg.targetDate);
  final link = ref.keepAlive();

  final closestStation = await ref.watch(closestStationProvider.future);

  final dioService = ref.read(httpServiceProvider);

  try {
    final resp = await dioService.request(
      TidesAndFeedingRequest(
          tideStation: closestStation!,
          strikeScore: arg.strikeScore,
          targetDate: arg.targetDate,
          timeZone: arg.timeZone,
          sunRise: arg.sunRise,
          sunSet: arg.sunSet),
      converter: (resp) {
        final json = jsonEncode(resp);
        return TidesAndFeedingResponse.fromMap(resp);
      },
    );
    return resp;
  } catch (e) {
    link.close();
    throw e;
  }
});

final strikeScoreForDayProvider = FutureProvider.family.autoDispose<DailyStrikeScore?, DateTime>((ref, arg) async {
  final List<DailyStrikeScore> value =
      await ref.watch(strikeScoreProvider.future).then((value) => value.dailyStrikeScore);

  final strike = value.firstWhereOrNull((element) {
    return element.dateTime.date == arg.date;
  });

  return strike;
});

final tideFillerForDayProvider = FutureProvider.family.autoDispose<List<TideFillerPeriod>, DateTime>((ref, arg) async {
  List<TideFillerPeriod> values = await ref.watch(strikeScoreProvider.future).then((value) => value.tidesFiller);
  values = values.where((element) => element.dateTimeISO.date == arg.date).toList();

  return values;
});

final moonPhaseForDayProvider = FutureProvider.family.autoDispose<MoonPhase?, DateTime>((ref, arg) async {
  List<MoonPhase> values = await ref.watch(strikeScoreProvider.future).then((value) => value.moonPhase);
  return values.firstWhereOrNull((element) => element.dateTimeISO.date == arg.date);
});

final forecastForDayProvider = FutureProvider.family.autoDispose<ForecastOfTheDay?, DateTime>((ref, arg) async {
  final List<ForecastOfTheDay> value =
      await ref.watch(strikeScoreProvider.future).then((value) => value.feedingOfTheDay.forecastOfTheDay);

  return value.firstWhereOrNull((element) {
    return element.dateTimeIso.date == arg.date;
  });
});

final availableCalendarDaysProvider = FutureProvider.autoDispose<List<DateTime>>((ref) async {
  ref.keepAlive();
  final List<DateTime> value = await ref
      .watch(strikeScoreProvider.future)
      .then((value) => value.dailyStrikeScore.map((e) => e.dateTime).toList());

  List<DateTime> fillerData = await ref
      .watch(strikeScoreProvider.future)
      .then((value) => value.tidesFiller.map((e) => e.dateTimeISO.date).toList());

  final combined = [...value, ...fillerData]..sort();

  return List.from(combined.toSet())..sort();
});

final tideFishingForecastProvider = FutureProvider.autoDispose<List<ForecastOfTheDay>>((
  ref,
) async {
  final station = await ref.watch(closestStationProvider.future);
  if (station == null) {
    throw NoNearbyTideStationException();
  }

  final http = ref.read(httpServiceProvider);

  try {
    final resp = await http.request(TideFishingForecastRequest(station), converter: (resp) {
      return (resp["result"]["forecast"] as List).map((e) => e["periods"]).map((e) {
        return ForecastOfTheDay.fromMap(e);
      }).toList();
    });

    return resp;
  } catch (e) {
    logger.info(e);
    return [];
  }
});

class GetDailyStrikeScoreRequest extends BaseHttpRequest {
  final TideStation tideStation;

  GetDailyStrikeScoreRequest(this.tideStation) : super(requestType: RequestType.post, endpoint: "/getDailyStrikeScore");

  @override
  Map<String, dynamic> toMap() {
    return {
      "lat": tideStation.lat,
      "lng": tideStation.lng,
    };
  }
}

class TideFishingForecastRequest extends BaseHttpRequest {
  final TideStation tideStation;

  TideFishingForecastRequest(this.tideStation)
      : super(requestType: RequestType.post, endpoint: "/getTideFishingForecast");

  @override
  Map<String, dynamic> toMap() {
    return {
      "stationid": tideStation.id,
    };
  }
}

class TidesDaySpec extends Equatable {
  final double strikeScore;
  final DateTime targetDate;
  final String timeZone;
  final int sunRise;
  final int sunSet;

  const TidesDaySpec({
    required this.strikeScore,
    required this.targetDate,
    required this.timeZone,
    required this.sunRise,
    required this.sunSet,
  });

  @override
  List<Object?> get props => [
        strikeScore,
        targetDate,
        timeZone,
        sunRise,
        sunSet,
      ];
}

class TidesAndFeedingRequest extends BaseHttpRequest {
  final TideStation tideStation;
  final double strikeScore;
  final DateTime targetDate;
  final String timeZone;
  final int sunRise;
  final int sunSet;
  TidesAndFeedingRequest({
    required this.tideStation,
    required this.strikeScore,
    required this.targetDate,
    required this.timeZone,
    required this.sunRise,
    required this.sunSet,
  }) : super(requestType: RequestType.post, endpoint: "/getTidesAndFeeding");
  @override
  Map<String, dynamic> toMap() {
    return {
      "lat": tideStation.lat,
      "lng": tideStation.lng,
      "strikeScore": strikeScore,
      "targetDate": targetDate.formattedDate,
      "sunRise": sunRise,
      "sunSet": sunSet,
      "timeZone": timeZone,
    };
  }
}

class NoNearbyTideStationException extends Error {}
