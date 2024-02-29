import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/landscape_orientation/bar_chart_widget_landscape.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/landscape_orientation/line_chart_widget_landscape.dart';

import '../../../../../../../services/markers/customized_providers.dart';
import '../../../../../controller/customized_providers.dart';
import '../../../../search_popup.dart';
import '../../../calendar/calendar.dart';
import '../chart_axis_values_widget.dart';
import '../line_chart_widget.dart';

class LandscapeOrientationGraph extends ConsumerStatefulWidget {
  const LandscapeOrientationGraph({
    super.key,
    required this.barsData,
    required this.lineGraphData,
    required this.maximumsY,
    required this.maxDateData,
    required this.isLoading,
  });

  // osY for blue bars
  final List<BarChartPoint> barsData;

  // tide data
  final List<GraphPoint> lineGraphData;

  // min and max tide points
  final Maximums maximumsY;

  // dailyStrikeScore.length; no of days for which we have graph data
  final int maxDateData;

  // is graph data loading
  final bool isLoading;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LandscapeOrientationGraphState();
}

class _LandscapeOrientationGraphState extends ConsumerState<LandscapeOrientationGraph> {
  @override
  Widget build(BuildContext context) {
    final viewPaddingRight = MediaQuery.of(context).viewPadding.right;
    final viewPaddingLeft = MediaQuery.of(context).viewPadding.left;
    final graphWidth = MediaQuery.of(context).size.width - 45 - viewPaddingRight - viewPaddingRight;
    final graphHeight = MediaQuery.of(context).size.height * 0.6;
    final selectedFilters = ref.watch(selectedFilterProvider);
    final selectedCalendarItemDate = ref.watch(selectedDateTimeProvider).date;
    final closest = ref.watch(closestStationProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Divider(
            color: SaltStrongColors.greyStroke,
            thickness: 1,
          ),
          // ------------------------ row with date buttons
          SizedBox(
            height: 35.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: selectedCalendarItemDate.date == DateTime.now().date
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No past data is available'),
                              ),
                            );
                          }
                        : () {
                            ref.read(calendarNotifierProvider.notifier).setSelectedDate(
                                  selectedCalendarItemDate.subtract(const Duration(hours: 24)),
                                  context,
                                  showSnackBar: false,
                                );
                            // TODO decrease date
                          },
                    child: const Text(
                      '-',
                      style: TextStyle(color: SaltStrongColors.black, fontWeight: FontWeight.w600),
                    )),
                const VerticalDivider(color: SaltStrongColors.greyStroke, thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: const Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const VerticalDivider(color: SaltStrongColors.greyStroke, thickness: 1),
                TextButton(
                    onPressed:
                        selectedCalendarItemDate.date == DateTime.now().date.add(Duration(days: widget.maxDateData - 1))
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No future data is available'),
                                  ),
                                );
                              }
                            : () {
                                ref.read(calendarNotifierProvider.notifier).setSelectedDate(
                                      selectedCalendarItemDate.add(const Duration(hours: 24)),
                                      context,
                                      showSnackBar: false,
                                    );
                                // TODO decrease date
                              },
                    child: const Text(
                      '+',
                      style: TextStyle(color: SaltStrongColors.black, fontWeight: FontWeight.w600),
                    )),
              ],
            ),
          ),
          // ------------------------ tide station name
          SafeArea(
            right: false,
            top: false,
            bottom: false,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Text(
                    closest.when(data: (closest) {
                      if (closest == null) return "No tide stations found.";
                      return "Station: ${closest.stationName}";
                    }, error: (err, st) {
                      return "No tide stations found.";
                    }, loading: () {
                      return "Loading, please wait...";
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                )),
          ),
          // ------------------------ today's date
          SafeArea(
            left: false,
            top: false,
            bottom: false,
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Text(
                    '${DateFormat('E').format(selectedCalendarItemDate)}, ${selectedCalendarItemDate.formattedDate}',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                )),
          ),
          // ------------------------ graph
          Padding(
            padding: EdgeInsets.only(left: viewPaddingLeft),
            child: SizedBox(
              height: graphHeight,
              width: double.infinity,
              child: widget.isLoading
                  ? const Align(alignment: Alignment.center, child: CircularProgressIndicator())
                  : Stack(alignment: Alignment.bottomLeft, children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 35.w,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VerticalDivider(
                              thickness: 1.r,
                              color: SaltStrongColors.greyStroke,
                              width: 1,
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  BarChartWidgetLandscape(
                                    barsData: widget.barsData,
                                    graphHeight: graphHeight,
                                    graphWidth: graphWidth,
                                  ),

                                  TranslucentPointer(
                                    child: Visibility(
                                      visible: selectedFilters.contains(SmartTidesFilter.tides),
                                       child: ClipRRect(
                                        child: LineChartWidgetLandscape(
                                          displayedDate: ref.watch(selectedDateProvider),
                                          points: widget.lineGraphData.toList(),
                                          maximumsY: widget.maximumsY,
                                          graphHeight: graphHeight,
                                          graphWidth: graphWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ------------------------ graph left sidebar
                      chartAxisValuesWidget(
                        context: context,
                        maximumsY: widget.maximumsY,
                        positionedLeft: 0,
                        positionedTop: 0,
                        graphWidth: graphWidth,
                        graphHeight: graphHeight,
                        hasBottomSpace: true,
                      ),
                      // ------------------------ vertical blue pointer
                      if (selectedCalendarItemDate == DateUtils.dateOnly(DateTime.now()))
                        Padding(
                          padding: EdgeInsets.only(left: 35.w + (graphWidth / 24 * DateTime.now().hour)),
                          child: Container(
                            width: 3.r,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: SaltStrongColors.verticalGraphPointer,
                              borderRadius: BorderRadius.all(Radius.circular(44)),
                            ),
                            // indent: 68,
                          ),
                        ),
                    ]),
            ),
          ),
        ]),
      );
    });
  }
}
