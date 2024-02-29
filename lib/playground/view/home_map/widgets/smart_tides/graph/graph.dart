import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/get_tides_and_feeding_response.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/search_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/calendar/calendar.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/bar_chart_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/chart_axis_values_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/daily_forecast_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/moon_info_widget.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/today_calendar_item.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/weather_card_item.dart';

import '../../../../../constants/colors.dart';
import '../../../controller/customized_providers.dart';

// used for initial graph scroll position
final dateTimeHourNow = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour);

class GraphWidget extends ConsumerStatefulWidget {
  GraphWidget({
    required this.lineGraphData,
    required this.barsData,
    required this.hourlyForecast,
    required this.dataForCalendarList,
    required this.dailyStrikeScore,
    required this.isLoading,
    required this.maximumsY,
    required this.dailyForecast,
  }) : super(key: PageStorageKey(dailyStrikeScore.toString()));

  // osY for blue bars
  final List<BarChartPoint> barsData;

  final List<GraphPoint> lineGraphData;

  // data for weather cards
  final List<ForecastOfTheDay> hourlyForecast;

  // data for calendar items
  final List<ForecastOfTheDay> dataForCalendarList;

  final List<DailyStrikeScore> dailyStrikeScore;

  final Maximums maximumsY;

  final bool isLoading;

  final DailyForecast dailyForecast;

  @override
  ConsumerState<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends ConsumerState<GraphWidget> {
  late List<ForecastOfTheDay> weatherList;

  late final ScrollController _timelineScrollController;
  late List<DateTime> timelineTimes;
  late final ScrollController listViewController;

  late final timelineWidth = (WeatherCardItem.width * weatherList.length) + 11.w;

  ScrollController? get timelineScrollController => //
      MediaQuery.of(context).orientation == Orientation.portrait ? _timelineScrollController : null;

  @override
  void initState() {
    suppressingScrollNotification = true;
    listViewController = ScrollController();
    weatherList = widget.hourlyForecast
        .map((hourForecast) => widget.hourlyForecast.indexOf(hourForecast).isEven ? hourForecast : null)
        .whereNotNull()
        .toList();
    timelineTimes = widget.barsData.map((e) => DateTime.fromMillisecondsSinceEpoch(e.x)).toList();

    _timelineScrollController = ScrollController();

    Future(() {
      updateScrollPositions();
    });
    _timelineScrollController.addListener(() {
      _calculateFeetPosition();
    });

    super.initState();
  }

  void updateScrollPositions() {
    _updateDayListPosition();
    _updateGraphPosition();
  }

  void _updateDayListPosition() {
    final selectedDateTime = ref.read(selectedDateTimeProvider);
    final x = offsetForDate(selectedDateTime.date);
    suppressingScrollNotification = true;
    listViewController.jumpTo(x);
    suppressingScrollNotification = false;
  }

  void _updateGraphPosition() {
    suppressingScrollNotification = true;
    if (timelineScrollController != null) {
      final selectedDateTime = ref.read(selectedDateTimeProvider);
      final offset = offsetForTime(TimeOfDay.fromDateTime(selectedDateTime));
      timelineScrollController!.jumpTo(offset);
    }
    _calculateFeetPosition();
    ref.read(calendarNotifierProvider.notifier).ref.notifyListeners();
    suppressingScrollNotification = false;
  }

  void _calculateFeetPosition() {
    if (timelineScrollController == null) return;
    setState(() {
      // _feetIndicatorPosition = max(0, (extraSpace - 35) - timelineScrollController.positions.first.pixels);
      _feetIndicatorPosition = max(
        0,
        timelineScrollController!.positions.first.pixels - (extraSpace - graphLeftSidebarWidth),
      );
    });
  }

  @override
  void didUpdateWidget(covariant GraphWidget oldWidget) {
    timelineTimes = widget.barsData.map((e) => DateTime.fromMillisecondsSinceEpoch(e.x)).toList();
    if (oldWidget.isLoading != this.widget.isLoading) {
      Future(() {
        _updateGraphPosition();
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  double offsetForTime(TimeOfDay time) {
    final percentage = time.inMinutes / const TimeOfDay(hour: 23, minute: 59).inMinutes;
    return timelineWidth * percentage;
  }

  double offsetForDate(DateTime date) {
    final dates = widget.dailyStrikeScore.map((e) => e.dateTime.date).toList();
    final index = dates.indexWhere((element) => element == date);
    final percentage = index / dates.length;

    return listViewController.position.maxScrollExtent * percentage;
  }

  DateTime timeForOffset(double offset) {
    final times = timelineTimes;
    try {
      return times[(offset / timelineWidth * times.length).floor()];
    } catch (e) {
      return times.last;
    }
  }

  final extraSpace = 12 + WeatherCardItem.width * 2;
  final graphLeftSidebarWidth = 35;

  bool suppressingScrollNotification = false;
  late double _feetIndicatorPosition = extraSpace;

  @override
  Widget build(BuildContext context) {
    final selectedFilters = ref.watch(selectedFilterProvider);

    final selectedCalendarItemDate = ref.watch(selectedDateTimeProvider).date;
     return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey('${widget.isLoading} ${MediaQuery.of(context).orientation}'),
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 8.h,
          ),

          /// ----------------- horizontal calendar cards
          SizedBox(
            height: 84.h,
            key: ValueKey(widget.dailyStrikeScore.toString()),
            child: ListView.separated(
              // we are using storage key because the ValueKey in Column which is used for AnimatedSwitcher, causes
              // total rebuilds so the position is not persisted
              key: PageStorageKey("key"),
              controller: listViewController,
              shrinkWrap: true,
              padding: EdgeInsets.only(
                left: 10.w,
                // top: 10.h,
                right: 10.w,
              ),
              separatorBuilder: (context, index) => SizedBox(
                width: 10.w,
              ),
              itemBuilder: (context, index) {
                final strikeScore = widget.dailyStrikeScore[index];
                return strikeScore.dateTime == selectedCalendarItemDate
                    ? TodayCalendarItem(date: strikeScore.dateTime, strikeScore: strikeScore.strikeScore)
                    : Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 64.h,
                            minWidth: 56.w,
                          ),
                          child: DayWidget(
                            date: strikeScore.dateTime,
                            strikeScore: strikeScore.strikeScore.toString(),
                            onTap: () {
                              final time = ref.read(selectedTimeProvider);
                              ref.read(calendarNotifierProvider.notifier).setSelectedDate(
                                    strikeScore.dateTime.copyWith(hour: time.hour),
                                    context,
                                    showSnackBar: false,
                                  );

                              Future(() {
                                _updateGraphPosition();
                              });
                            },
                            isSelected: false,
                            isForGraphView: true,
                          ),
                        ),
                      );
              },
              scrollDirection: Axis.horizontal,
              itemCount: widget.dailyStrikeScore.length,
            ),
          ),
          Divider(
            thickness: 1.h,
            color: Colors.black,
            height: 0,
          ),

          /// ----------------- parent horizontal scroll widget
          Expanded(
            child: Stack(
              children: [
                Opacity(
                  opacity: widget.isLoading ? 0 : 1,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      NotificationListener(
                        onNotification: (noti) {
                          if (suppressingScrollNotification || widget.isLoading) return true;

                          if (noti is ScrollUpdateNotification || noti is ScrollEndNotification) {
                            if (noti is ScrollUpdateNotification) if (noti.dragDetails == null) return true;

                            if (timelineScrollController != null) {
                              final position = timelineScrollController!.offset;
                              final date = timeForOffset(position);
                              ref
                                  .read(calendarNotifierProvider.notifier)
                                  .updateSelectedDateTime(date);
                            }
                          }

                          return true;
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: timelineScrollController,
                          // barColumn width * no of barColumns + barColumn's vertical separators - half of screen size
                          physics: const ClampingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Opacity(
                                opacity: widget.isLoading ? 0 : 1,
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.all(8.r),
                                    alignment: Alignment.topCenter,
                                    width: extraSpace - graphLeftSidebarWidth,
                                    //  padding: EdgeInsets.only(right: graphLeftSidebarWidth.toDouble()),
                                    child: DailyForecastWidget(
                                      dailyForecast: widget.dailyForecast,
                                    ),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                child: Stack(children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: graphLeftSidebarWidth.toDouble()),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 145 + WeatherCardItem.height,
                                          child: VerticalDivider(
                                            thickness: 1.r,
                                            color: SaltStrongColors.greyStroke,
                                            width: 1,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// ----------------- weather cards
                                            SizedBox(
                                              height: 70.h,
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final hourData = weatherList[index];

                                                  return WeatherCardItem(
                                                    timestamp: hourData?.timestamp ?? 0,
                                                    icon: CachedNetworkImage(
                                                      imageUrl:
                                                          "https://cdn.aerisapi.com/wxicons/v2/${hourData?.icon}",
                                                      width: 14,
                                                      height: 14,
                                                    ),
                                                    temperature: hourData?.tempF ?? 0,
                                                    windMinMPH: hourData?.windSpeedMinMph ?? 0,
                                                    windMaxMPH: hourData?.windSpeedMaxMph ?? 0,
                                                    windDirection: hourData?.windDir ?? '',
                                                  );
                                                },
                                                scrollDirection: Axis.horizontal,
                                                itemCount: weatherList.length,
                                                separatorBuilder: (BuildContext context, int index) =>
                                                    VerticalDivider(
                                                  thickness: 1.r,
                                                  color: SaltStrongColors.greyStroke,
                                                  width: 1,
                                                ),
                                              ),
                                            ),

                                            /// ----------------- graph (barChart & lineChart)
                                            Stack(
                                              children: [
                                                SizedBox(
                                                    width: timelineWidth,
                                                    height: 190,
                                                    child: BarChartWidget(
                                                      barsData: widget.barsData,
                                                    )),
                                                Visibility(
                                                  visible: selectedFilters.contains(SmartTidesFilter.tides),
                                                  child: SizedBox(
                                                      width: timelineWidth,
                                                      height: 145,
                                                      child: ClipRRect(
                                                        child: LineChartWidget(
                                                          displayedDate: ref.watch(selectedDateProvider),
                                                          points: widget.lineGraphData.toList(),
                                                          maximumsY: widget.maximumsY,
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ------------------------ graph left sidebar
                                  chartAxisValuesWidget(
                                    context: context,
                                    maximumsY: widget.maximumsY,
                                    positionedLeft: _feetIndicatorPosition,
                                    positionedTop: WeatherCardItem.height ,
                                  ),
                                ]),
                              ),
                              VerticalDivider(
                                thickness: 1.r,
                                color: SaltStrongColors.greyStroke,
                                width: 1,
                              ),
                              SizedBox(
                                // height: double.infinity,
                                width: extraSpace,
                                child: Center(
                                  child: LayoutBuilder(builder: (context, constraints) {
                                    return SizedBox(
                                      height: constraints.maxHeight - 20,
                                      // height: double.infinity,
                                      width: extraSpace,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              alignment: Alignment.bottomCenter,
                                              width: extraSpace,
                                              padding: EdgeInsets.only(right: 0),
                                              child: MoonInfoWidget(
                                                dailyForecast: widget.dailyForecast,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ---------------- vertical blue graph pointer
                      Container(
                        margin: EdgeInsets.only(
                          top: WeatherCardItem.height - 8.h,
                          left: MediaQuery.of(context).size.width * 0.5,
                        ),
                        width: 3.r,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: SaltStrongColors.verticalGraphPointer,
                          borderRadius: BorderRadius.all(Radius.circular(44)),
                        ),
                        // indent: 68,
                      ),
                    ],
                  ),
                ),
                if (widget.isLoading) const Align(alignment: Alignment.center, child: CircularProgressIndicator())
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on TimeOfDay {
  int get inMinutes => hour * 60 + minute;
}
