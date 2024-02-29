import 'package:equatable/equatable.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/get_tides_and_feeding_response.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';

class GraphDataState extends Equatable {
  final List<BarChartPoint> barsData;
  final List<ForecastOfTheDay> hourlyForecast;
  final List<ForecastOfTheDay> calendarData;
  final List<DailyStrikeScore> dailyStrikeScore;
  final List<GraphPoint> lineGraphData;
  final bool isLoadingGraphData;
  final Maximums maximumsY;
  final DailyForecast dailyForecast;
  const GraphDataState({
    required this.dailyStrikeScore,
    required this.maximumsY,
    required this.lineGraphData,
    required this.hourlyForecast,
    required this.barsData,
    required this.calendarData,
    required this.isLoadingGraphData,
    required this.dailyForecast,
  });

  @override
  List<Object?> get props =>
      [lineGraphData, hourlyForecast, barsData, calendarData, dailyStrikeScore, isLoadingGraphData, maximumsY, dailyForecast];

  bool get graphValid {
    if (lineGraphData.isEmpty ||
        dailyStrikeScore.isEmpty ||
        hourlyForecast.isEmpty ||
        barsData.isEmpty ||
        calendarData.isEmpty) {
      return false;
    }
    return true;
  }

  GraphDataState copyWith({
    List<BarChartPoint>? barsData,
    List<ForecastOfTheDay>? hourlyForecast,
    List<ForecastOfTheDay>? calendarData,
    List<DailyStrikeScore>? dailyStrikeScore,
    List<GraphPoint>? lineGraphData,
    bool? isLoadingGraphData,
    double? offset,
    Maximums? maximumsY,
    DailyForecast? dailyForecast,
  }) {
    return GraphDataState(
      maximumsY: maximumsY ?? this.maximumsY,
      barsData: barsData ?? this.barsData,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      calendarData: calendarData ?? this.calendarData,
      dailyStrikeScore: dailyStrikeScore ?? this.dailyStrikeScore,
      lineGraphData: lineGraphData ?? this.lineGraphData,
      isLoadingGraphData: isLoadingGraphData ?? this.isLoadingGraphData,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}
