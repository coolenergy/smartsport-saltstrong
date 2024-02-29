import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/get_tides_and_feeding_response.dart';
import 'package:salt_strong_poc/playground/services/tide_station/calendar_provider.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/daily_forecast_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';

import '../../../constants/colors.dart';
import '../widgets/salt_strong_snackbar.dart';
import 'graph_data_state.dart';

export 'customized_providers.dart';

final graphDataProvider = FutureProvider.autoDispose<GraphDataState>((ref) async {
  final link = ref.keepAlive();

  var selectedDate = ref.watch(selectedDateProvider);
  if (selectedDate.isBefore(DateTime.now().date)) {
    selectedDate = DateTime.now().date;
  }

  if (ref.state.hasValue) {
    final GraphDataState oldState = ref.state.value!;
    ref.state = AsyncData(oldState.copyWith(isLoadingGraphData: true));
  }

  final strikeScore = await ref.watch(strikeScoreProvider.future);

  List<ForecastOfTheDay> hourlyForecast = strikeScore.feedingOfTheDay.forecastOfTheDay;

  List<ForecastOfTheDay> dataForCalendar = strikeScore.feedingOfTheDay.forecastOfTheDay;

  final DailyStrikeScore? dayStrikeScore =
      strikeScore.dailyStrikeScore.firstWhereOrNull((element) => element.dateTime.date == selectedDate.date);
  final sunMoon = strikeScore.sunMoon.firstWhereOrNull((element) => element.dateTimeIso.date == selectedDate.date);

  if (dayStrikeScore == null) {
    throw Exception('Strike Score not found for $selectedDate');
  }
  if (sunMoon == null) {
    throw Exception('Sun/Moon not found for $selectedDate');
  }

  final TidesAndFeedingResponse tidesAndFeedingForTheDay = await ref.watch(tidesAndFeedingProvider(TidesDaySpec(
    strikeScore: dayStrikeScore.strikeScore,
    targetDate: selectedDate.date,
    timeZone: strikeScore.timeZone,
    sunRise: sunMoon.sun.rise,
    sunSet: sunMoon.sun.sunSet,
  )).future);

  if (ref.state.hasValue) {
    final GraphDataState oldState = ref.state.value!;
    ref.state = AsyncData(oldState.copyWith(isLoadingGraphData: false));
  }

  List<TidePeriod> tideList = tidesAndFeedingForTheDay.tidePeriods;

  List<GraphPoint> lineGraphDataJustForSelectedDay = tideList
      .where((element) => element.dateTime.date == selectedDate.date)
      .map((e) => GraphPoint(e.dateTime.millisecondsSinceEpoch.toDouble(), e.heightFt))
      .toList();

  List<GraphPoint> lineGraphData =
      tideList.map((e) => GraphPoint(e.dateTime.millisecondsSinceEpoch.toDouble(), e.heightFt)).toList();

  final dailyStrikeScores = strikeScore.dailyStrikeScore;

  final barsData = tidesAndFeedingForTheDay.feedingActivityArr
      // only show for selected date, api gives tomorrows data as well
      .where((element) => element.dateTimeIso.date == selectedDate.date)
      .map((e) => BarChartPoint(e.dateTimeIso.millisecondsSinceEpoch, e.feedingVal))
      .toList();

  final allYForDay = [
    ...lineGraphDataJustForSelectedDay.map((e) => e.y),
  ]..sort();

  var minValue = allYForDay.first;
  bool isNegative = minValue < 0;

  if (isNegative) {
    minValue = minValue.abs().ceil().toDouble();

    minValue = minValue * -1;
  }

  /// -------------------daily forecast before graph
  ///
  ///
  final dailyTemperatures = tidesAndFeedingForTheDay.forecastOfTheDay.map((e) => e.tempF).toList()..sort();
  final dailyForecast = DailyForecast(
    moonIcon: dayStrikeScore.moonIcon,
    shortWeather: dayStrikeScore.weatherPrimary ?? '',
    dayIcon: "https://cdn.aerisapi.com/wxicons/v2/${dayStrikeScore.icon}",
    sunRise: sunMoon.sun.riseIso,
    sunSet: sunMoon.sun.setIso,
    weatherSummary: tidesAndFeedingForTheDay.summary.long,
    windSpeedMinMph: dayStrikeScore.windSpeedMinMPH.toInt(),
    windSpeedMaxMph: dayStrikeScore.windSpeedMaxMPH.toInt(),
    windGustMph: dayStrikeScore.windGustMPH.toInt(),
    tempMinF: dailyTemperatures.first,
    tempMaxF: dailyTemperatures.last,
    moonNamePhase: sunMoon.moon?.phaseName ?? '',
    moonRise: sunMoon.moon?.riseIso,
    moonSet: sunMoon.moon?.setIso,
  );

  final state = GraphDataState(
    calendarData: dataForCalendar,
    barsData: barsData,
    hourlyForecast: hourlyForecast,
    dailyStrikeScore: dailyStrikeScores,
    lineGraphData: lineGraphData,
    isLoadingGraphData: false,
    maximumsY: Maximums(minValue, allYForDay.last.toDouble().toInt() + 1.0),
    dailyForecast: dailyForecast,
  );

  if (state.graphValid == false) {
    print('Graph data is invalid');
    throw Exception('Graph data is invalid');
  }

  return state;
});

void showTideInfoSnackBar(BuildContext context, List<TideFillerPeriod> tideFillers, MoonPhase? moonPhase) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).clearSnackBars();

  String tidesText = tideFillers //
      .sortedByCompare((t) => t.dateTimeISO, (a, b) => a.compareTo(b))
      .map((t) => t.formatted)
      .toList()
      .join('\n');

  if (moonPhase != null) {
    tidesText = '$tidesText\n${moonPhase.name.split(" ").map((e) => e.capitalize()).join(" ")}';
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(15.w, 5.h, 15.w, 20.h),
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: SaltStrongSnackbar(
        snackbarMessageFixed: 'Tide Info:\n$tidesText',
        snackbarMessageVariable: '',
        isForCalendar: true,
        textStyle: const TextStyle(
          color: SaltStrongColors.primaryBlue,
          fontSize: 15.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ));
}
