import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/custom_grid_delegate.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';
import 'package:salt_strong_poc/playground/services/polygons/polygon_service.dart';
import 'package:salt_strong_poc/playground/services/tide_station/calendar_provider.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/graph_data_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/salt_strong_snackbar.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/ss_bottom_sheet.dart';

class CalendarState {
  final DateTime selectedTime;
  final DateTime displayedMonth;

  const CalendarState({
    required this.selectedTime,
    required this.displayedMonth,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarState &&
          runtimeType == other.runtimeType &&
          selectedTime == other.selectedTime &&
          displayedMonth == other.displayedMonth;

  @override
  int get hashCode => selectedTime.hashCode ^ displayedMonth.hashCode;

  CalendarState copyWith({
    DateTime? selectedDateTime,
    DateTime? displayedDate,
    List<String>? selectedFilters,
  }) {
    return CalendarState(
      selectedTime: selectedDateTime ?? this.selectedTime,
      displayedMonth: displayedDate ?? displayedMonth,
    );
  }
}

final calendarNotifierProvider = NotifierProvider.autoDispose<CalendarNotifier, CalendarState>(
  () => CalendarNotifier(),
);

class CalendarNotifier extends AutoDisposeNotifier<CalendarState> {
  @override
  CalendarState build() {
    ref.keepAlive();
    Future(() {
      updateSelectedDateTime(DateTime.now());
    });
    return CalendarState(
      selectedTime: DateTime.now(),
      displayedMonth: DateTime.now().asMonth,
    );
  }

  // called when user taps on a date
  void setSelectedDate(DateTime date, BuildContext context, {showSnackBar = true}) {
    debugCheckHasScaffoldMessenger(context);

    // completely refreshing smart spots on date change so that they get removed from screen
    // and shown X seconds later with updated data
    if (ref.read(saltStrongLayerControllerProvider).isSmartSpotEnabled) {
      ref.refresh(polygonLoaderProvider(PolygonType.smartSpots));
    }

    final currentTime = state.selectedTime.timeOfDay;

    state = state.copyWith(selectedDateTime: date.date.copyWith(hour: currentTime.hour));

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).clearSnackBars();

    if (showSnackBar) {
      showCalendarTideInfoSnackBar(
        date,
        null,
        context,
      );
    }
  }

  void showCalendarTideInfoSnackBar(DateTime date, MoonPhase? moonPhase, BuildContext context) {
    final tideFillers = ref.read(tideFillerForDayProvider(date)).valueOrNull;
    if (tideFillers == null || tideFillers.isEmpty) return;
    showTideInfoSnackBar(context, tideFillers, moonPhase);
  }

  // called when user drags the timeline
  void updateSelectedDateTime(DateTime dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }
}

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  final pageViewController = PageController(initialPage: 0);
  int _index = 0;

  int itemCount = 0;

  @override
  Widget build(BuildContext context) {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    const double height = 346;

    return SizedBox(
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              ref.read(smartTidesTabBarViewIndex.notifier).state = 0;
            },
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          'Strike Score Calendar',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays
                .map(
                  (day) => Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 9.h,
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Flexible(
            child: LayoutBuilder(builder: (context, constraints) {
              final daysCount = ref.watch(availableCalendarDaysProvider).valueOrNull;
              if (daysCount == null) {
                return const SizedBox();
              }
              if (daysCount.isEmpty) {
                return const SizedBox();
              }
              // 21 days per grid
              final gridsCount = (daysCount!.length / 21).round();

              final weeks = groupIntoWeeks(daysCount.first, daysCount.last);
              itemCount = (weeks.length / 3).ceil();

              return PageView.builder(
                controller: pageViewController,
                itemCount: itemCount,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                  });
                },
                itemBuilder: (context, index) {
                  // group weeks into 3 weeks(or less) per grid
                  final grouped = weeks.sublist(index * 3, min((index * 3) + 3, weeks.length));

                  return CalendarGrid(days: grouped.expand((element) => element).toList());
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_index != 0)
                      Container(
                        height: 38,
                        width: 64,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(Radius.circular(8))),
                        child: IconButton(
                          icon: SvgPicture.asset(Assets.icons.leftArrow.path),
                          onPressed: () {
                            pageViewController.jumpTo(pageViewController.offset);

                            pageViewController.previousPage(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                          },
                        ),
                      )
                    else
                      Spacer(),
                    if (_index != itemCount - 1)
                      Container(
                        height: 38,
                        width: 64,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(Radius.circular(8))),
                        child: IconButton(
                          icon: SvgPicture.asset(Assets.icons.rightArrow.path),
                          onPressed: () {
                            pageViewController.jumpTo(pageViewController.offset);
                            pageViewController.nextPage(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<List<DateTime>> groupIntoWeeks(DateTime firstDate, DateTime lastDate) {
    List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    // Fill the first week with days before the firstDate to start on Sunday
    while (firstDate.weekday != DateTime.sunday) {
      firstDate = firstDate.subtract(Duration(days: 1));
      currentWeek.insert(0, firstDate);
    }

    // Add days from firstDate to lastDate
    while (firstDate.isBefore(lastDate) || firstDate.isAtSameMomentAs(lastDate)) {
      currentWeek.add(firstDate);
      if (firstDate.weekday == DateTime.saturday) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
      firstDate = firstDate.add(Duration(days: 1));
    }

    // Fill the last week with days after the lastDate to end on Saturday
    // while (lastDate.weekday != DateTime.saturday) {
    //   lastDate = lastDate.add(Duration(days: 1));
    //   currentWeek.add(lastDate);
    // }

    // Add the last week to the list
    weeks.add(currentWeek);

    return weeks.map((e) => e.toSet().toList()).toList();
  }
}

class CalendarGrid extends StatefulWidget {
  final List<DateTime> days;
  const CalendarGrid({
    super.key,
    required this.days,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, snapshot) {
      final maxHeight = snapshot.maxHeight;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          shrinkWrap: false,
          itemCount: widget.days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisCount: 7,
            height: maxHeight / 3,
          ),
          itemBuilder: (context, index) {
            return Consumer(builder: (context, ref, _) {
              final date = widget.days[index];
              ref
                  .watch(strikeScoreProvider.future)
                  .then((value) => value.feedingOfTheDay.forecastOfTheDay);

              DailyStrikeScore? strikeScoreForDay =
                  ref.watch(strikeScoreForDayProvider(date)).valueOrNull;
              List<TideFillerPeriod>? tidesFillerPeriodForDay =
                  ref.watch(tideFillerForDayProvider(date)).valueOrNull;

              MoonPhase? moonPhaseForDay = ref.watch(moonPhaseForDayProvider(date)).valueOrNull;

              bool isBeforeToday = date.isBefore(DateTime.now().date);
              return FittedBox(
                child: Opacity(
                  opacity: isBeforeToday ? 0.0 : 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 4.w),
                    child: DayWidget(
                      date: date,
                      moonIcon: moonPhaseForDay == null
                          ? null
                          : CachedNetworkImage(
                              imageUrl: moonPhaseForDay.moonIcon,
                              width: 24,
                              height: 24,
                            ),
                      strikeScore: strikeScoreForDay?.strikeScore.toString(),
                      weatherIcon: strikeScoreForDay == null
                          ? null
                          : CachedNetworkImage(
                              imageUrl:
                                  "https://cdn.aerisapi.com/wxicons/v2/${strikeScoreForDay.icon}",
                              width: 14,
                              height: 14,
                            ),
                      onTap: () {
                        if (strikeScoreForDay == null) {
                          ref //
                              .read(calendarNotifierProvider.notifier)
                              .showCalendarTideInfoSnackBar(date, moonPhaseForDay, context);
                        } else {
                          ref.read(calendarNotifierProvider.notifier).setSelectedDate(
                                date,
                                context,
                                showSnackBar: false,
                              );
                        }
                      },
                      isSelected: ref.watch(selectedDateTimeProvider).isSameDay(date),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }
}

class DayWidget extends ConsumerWidget {
  const DayWidget(
      {super.key,
      required this.date,
      this.strikeScore,
      this.weatherIcon,
      required this.onTap,
      required this.isSelected,
      this.isForGraphView = false,
      this.moonIcon});

  final Widget? weatherIcon;
  final Widget? moonIcon;
  final DateTime date;
  final String? strikeScore;
  final bool isSelected;
  final Function() onTap;
  final bool isForGraphView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateController = ref.watch(selectedDateTimeProvider);
    DateTime? selectedDate = selectedDateController;
    final month = DateFormat('MMM').format(date);
    final day = DateFormat('d').format(date);
    final weekday = DateFormat('E').format(date).toUpperCase();
    final today = DateTime.now();

    bool isSelected = selectedDate.day == date.day &&
        selectedDate.month == date.month &&
        selectedDate.year == date.year;

    bool isToday = today.day == date.day && today.month == date.month && today.year == date.year;

    bool isPast = date.isBefore(today);

    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      borderColor = Colors.black;
    } else {
      borderColor = SaltStrongColors.greyStroke.withOpacity(0.4);
    }
    if (isForGraphView) {
      backgroundColor = SaltStrongColors.greyStroke.withOpacity(0.4);
    } else {
      if (isToday) {
        backgroundColor = SaltStrongColors.seaFoam;
      } else if (isPast) {
        backgroundColor = SaltStrongColors.greyStroke.withOpacity(0.4);
      } else {
        backgroundColor = Colors.white;
      }
    }

    // int? strikeScore =
    //     ref.watch(forecastForDayProvider(date)).when(data: (data) {
    //   return data?.tempC;
    // }, error: (err, st) {
    //   debugPrint(st.toString());
    //   return null;
    // }, loading: () {
    //   return null;
    // });

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 64.h,
          minWidth: 49.w,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
              color: backgroundColor == SaltStrongColors.greyStroke.withOpacity(0.4)
                  ? Colors.transparent
                  : borderColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: buildDay(weekday, month, day),
      ),
    );
  }

  Column buildDay(String weekday, String month, String day) {
    final text = strikeScore;
    if (!isForGraphView) {
      final children = [
        Padding(
          padding: weatherIcon == null ? EdgeInsets.only(top: 3, bottom: 6.r) : EdgeInsets.all(4.r),
          child: Text(
            '$month, $day',
            style: TextStyle(fontSize: 10.sp),
          ),
        ),
        if (weatherIcon != null)
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: weatherIcon!,
          ),
        if (text != null)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: FittedBox(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: double.parse(text).color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else if (moonIcon != null)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: moonIcon!,
          ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    final children = [
      const Spacer(flex: 2),
      Text(
        weekday,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
      ),
      if (weatherIcon != null)
        Padding(
          padding: EdgeInsets.only(top: 7.h),
          child: weatherIcon!,
        ),
      const Spacer(),
      Padding(
        padding: weatherIcon == null ? EdgeInsets.zero : EdgeInsets.all(4.r),
        child: Text(
          '$month, $day',
          style: TextStyle(fontSize: 10.sp),
        ),
      ),
      const Spacer(flex: 2),
      Expanded(
        flex: 9,
        child: FittedBox(
          child: Text(
            strikeScore!,
            style: TextStyle(
              fontSize: 17.sp,
              color: double.parse(strikeScore!).color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const Spacer(flex: 2),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
