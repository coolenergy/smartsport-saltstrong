import 'dart:math';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/services/tide_station/calendar_provider.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_state.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/calendar/calendar.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/graph.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';

import '../../../../gen/assets.gen.dart';
import '../../../modelsV2/layer_option.dart';
import '../controller/graph_data_controller.dart';
import 'layers_widgets/custom_list_tile.dart';
import 'layers_widgets/layer_row.dart';
import 'layers_widgets/map_layers_container.dart';
import 'layers_widgets/transparency_popup.dart';

class SaltStrongBottomSheet extends ConsumerStatefulWidget {
  static double get height => 420.h;

  static double get tabHeight => 48.h;

  const SaltStrongBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<SaltStrongBottomSheet> createState() => _SaltStrongBottomSheetState();
}

class _SaltStrongBottomSheetState extends ConsumerState<SaltStrongBottomSheet> {
  List<String> selectedElements = [];
  List<String> selectedSpotTypes = [];
  List<String> selectedMapLayers = [];

  // int smartTidesTabBarViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final layersState = ref.watch(saltStrongLayerControllerProvider);
    final controller = ref.read(saltStrongLayerControllerProvider.notifier);
    final getSmartTidesTabBarViewIndex = ref.watch(smartTidesTabBarViewIndex);

    return SizedBox(
      height: SaltStrongBottomSheet.height + 10.h,
      width: MediaQuery.sizeOf(context).width,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Builder(builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildTabBar(context),
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        selectSmartTidesTabBarView(
                          getSmartTidesTabBarViewIndex,
                        ),
                        LayersTab(layersState: layersState, controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  TabBar buildTabBar(BuildContext context) {
    return TabBar(
      isScrollable: true,
      onTap: (index) {
        setState(() {
          ref.read(defaultTabCtrlIndex.notifier).state = index;
        });
      },
      indicatorWeight: 0.2,
      indicatorColor: Colors.transparent,
      unselectedLabelColor: Colors.black54,
      labelColor: Colors.black,
      labelPadding: EdgeInsets.zero,
      tabs: [
        SizedBox(
          width: DefaultTabController.of(context).index == 0
              ? MediaQuery.of(context).size.width / 3 * 2
              : MediaQuery.of(context).size.width / 3,
          child: ColorTab(
            selected: DefaultTabController.of(context).index == 0,
            child: Tab(
              height: SaltStrongBottomSheet.tabHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: smartTidesTab(DefaultTabController.of(context).index == 0),
              ),
            ),
          ),
        ),
        SizedBox(
          width: DefaultTabController.of(context).index == 1
              ? MediaQuery.of(context).size.width / 3 * 2
              : MediaQuery.of(context).size.width / 3,
          child: ColorTab(
              selected: DefaultTabController.of(context).index == 1,
              child: Tab(
                height: SaltStrongBottomSheet.tabHeight,
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Layers'),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  List<Widget> smartTidesTab(
    bool selected,
  ) {
    if (!selected) {
      return [
        const Expanded(child: Center(child: Text('Smart Tides'))),
      ];
    }
    final getSmartTidesTabBarViewIndex = ref.watch(smartTidesTabBarViewIndex);
    return [
      Expanded(
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Stack(children: [
                // Row was wrapped in InkWell()
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Smart Tides',
                      ),
                    ),
                    // SizedBox(width: 20.w,),
                  ],
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ref.read(smartTidesTabBarViewIndex.notifier).state = 0;
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ]),
            ),
            const VerticalDivider(
              width: 0,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                ref.read(smartTidesTabBarViewIndex.notifier).state = 1;
              },
              child: Container(
                color:
                    getSmartTidesTabBarViewIndex == 1 ? SaltStrongColors.black : Colors.transparent,
                width: 48,
                height: SaltStrongBottomSheet.tabHeight,
                child: SvgPicture.asset(
                  Assets.icons.calendar.path,
                  width: 16.w,
                  height: 16.h,
                  fit: BoxFit.scaleDown,
                  colorFilter: ColorFilter.mode(
                    getSmartTidesTabBarViewIndex == 1
                        ? SaltStrongColors.white
                        : SaltStrongColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 0,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                ref.read(smartTidesTabBarViewIndex.notifier).state = 2;
              },
              child: Container(
                color:
                    getSmartTidesTabBarViewIndex == 2 ? SaltStrongColors.black : Colors.transparent,
                width: 48,
                height: SaltStrongBottomSheet.tabHeight,
                child: SvgPicture.asset(
                  Assets.icons.filter.path,
                  width: 16.w,
                  height: 16.h,
                  fit: BoxFit.scaleDown,
                  colorFilter: ColorFilter.mode(
                    getSmartTidesTabBarViewIndex == 2
                        ? SaltStrongColors.white
                        : SaltStrongColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget selectSmartTidesTabBarView(
    int index,
  ) {
    Widget tabBarView = const SizedBox();
    switch (index) {
      case 0:
        tabBarView = Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(graphDataProvider);
            return state.when(
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                data: (value) {
                  return GraphWidget(
                    dailyStrikeScore: value.dailyStrikeScore,
                    lineGraphData: value.lineGraphData,
                    //lineGraphData: [Point(1694392500000.0, 1.851), Point(1694405040000.0, 1.653), Point(1694427480000.0, 2.534), Point(1694454540000.0, 0.278), Point(1694479500000.0, 1.856), Point(1694494440000.0, 1.474), Point(1694516880000.0, 2.579), Point(1694542800000.0, 0.348), Point(1694566380000.0, 1.876), Point(1694583240000.0, 1.282), Point(1694605800000.0, 2.582), Point(1694630700000.0, 0.464), Point(1694653080000.0, 1.929), Point(1694671800000.0, 1.086), Point(1694694420000.0, 2.541), Point(1694718360000.0, -0.613), Point(1694739780000.0, 2.028), Point(1694760300000.0, 0.892), Point(1694782980000.0, 2.46), Point(1694805840000.0, 0.776), Point(1694826660000.0, 2.167), Point(1694848800000.0, 0.708), Point(1694871660000.0, 2.348), Point(1694893200000.0, 0.941), Point(1694913900000.0, 2.328), Point(1694937420000.0, 0.55), Point(1694960400000.0, 2.211), Point(1694980620000.0, 1.102), Point(1695001440000.0, 2.481), Point(1695026280000.0, 0.431), Point(1695049500000.0, 2.051),], // todo delete, testing purposes only
                    barsData: value.barsData,
                    hourlyForecast: value.hourlyForecast,
                    dataForCalendarList: value.calendarData,
                    isLoading: value.isLoadingGraphData,
                    maximumsY: value.maximumsY,
                    // maximumsY: Maximums(-0.613, 3.0),  // todo delete, testing purposes only
                    dailyForecast: value.dailyForecast,
                  );
                },
                error: (err, st) {
                  if (err is NoNearbyTideStationException) {
                    return const Center(
                      child: Text("No nearby Tide Stations"),
                    );
                  }
                  print(err);
                  print(st);
                  debugPrintStack(stackTrace: st);
                  return const Center(
                    child: Text('There has been unexpected error. Please try again later.'),
                  );
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                });
          },
        );
        break;
      case 1:
        tabBarView = const CalendarWidget();
        break;
      case 2:
        tabBarView = const FilterWidget();
        break;
    }
    return tabBarView;
  }
}

class LayersTab extends StatelessWidget {
  const LayersTab({
    super.key,
    required this.layersState,
    required this.controller,
  });

  final SaltMapState layersState;
  final SaltMapLayerController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 3.h),

          /// SPOT TYPES
          LayerRow(
            title: 'Spot Types',
            children: [
              ...layersState.spotTypes.map((e) => CustomListTile(
                    title: e.name,
                    isSelected: e.isEnabled,
                    icon: e.icon,
                    onSelected: (bool value) {
                      controller.toggleLayer(
                        layer: e,
                        isEnabled: value,
                      );
                    },
                  ))
            ],
          ),

          /// ELEMENTS
          LayerRow(
            title: 'Elements',
            children: [
              ...layersState.elements.map((e) => CustomListTile(
                    title: e.name,
                    isSelected: e.isEnabled,
                    icon: e.icon,
                    onSelected: (bool value) {
                      controller.toggleLayer(
                        layer: e,
                        isEnabled: value,
                      );
                    },
                  ))
            ],
          ),

          /// MAP LAYERS
          LayerRow(
            title: 'Map Layers',
            children: [
              ...layersState.mapLayers.map((e) => MapLayersListTile(
                    onOptionsTap: () {
                      TransparencyPopUp(
                        selectedLayerTitle: e.name,
                        selectedLayerImage: e.icon,
                        onTransparencyChanged: (double value) {
                          controller.updateLayerOpacity(e, value);
                        },
                        onOptionSelected: (LayerOption option) {
                          controller.updateLayerOption(
                            layer: e,
                            option: option,
                          );
                        },
                        options: e.options,
                        initialTransparency: e.opacity,
                        initialOption: e.options.elementAtOrNull(e.selectedOptionIndex),
                      ).show(context);
                    },
                    title: e.name,
                    isSelected: e.isEnabled,
                    image: e.icon,
                    onSelected: (bool value) {
                      controller.toggleLayer(
                        layer: e,
                        isEnabled: value,
                      );
                    },
                  ))
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  showLayerSnackbar(
                    context,
                    text: 'Showing initial layers',
                  );
                  controller.initLayers();
                },
                child: Text(
                  'Reset',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  showLayerSnackbar(
                    context,
                    text: 'Saving layers...',
                  );
                  await controller.saveLayersToStorage();
                },
                child: Text(
                  'Save Layers',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  showLayerSnackbar(
                    context,
                    text: 'Showing saved layers',
                  );
                  await controller.showSavedLayersOnMap();
                },
                child: Text(
                  'Load Layers',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showLayerSnackbar(BuildContext context, {required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}

class ColorTab extends StatelessWidget {
  final Tab child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: selected ? Colors.white : Colors.white.withOpacity(0.8),
        child: child,
      ),
    );
  }

  const ColorTab({
    super.key,
    required this.child,
    required this.selected,
  });
}
