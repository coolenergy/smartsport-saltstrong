import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/models/map_position.dart';
import 'package:salt_strong_poc/playground/view/home_map/animated_map_button.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/current_date_provider.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/collapsable_smart_spot_legen.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/search_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/landscape_orientation/landscape_orientation_graph.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/ss_bottom_sheet.dart';
import 'package:salt_strong_poc/routing/router.dart';

import '../../../auth/widgets/welcome_back_dialog.dart';
import '../../../gen/assets.gen.dart';
import '../../modelsV2/layer_wrapper.dart';
import '../../services/search/location_search_service.dart';
import '../../services/tide_station/calendar_provider.dart';
import 'controller/graph_data_controller.dart';
import 'controller/layer_controller.dart';
import 'controller/location_search_controller.dart';
import 'search/search_bar.dart';

const int mapMaxZoom = 18;
const int mapMinZoom = 3;

class MapHomePage extends ConsumerStatefulWidget {
  const MapHomePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MapHomePage> createState() => _LeafletMapState();
}

class _LeafletMapState extends ConsumerState<MapHomePage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBottomSheetOpen = false;
  double _bottomSheetHeight = 0;

  @override
  void initState() {
    super.initState();
    try {
      print(ref.read(currentDeviceDateProvider));
      ref.read(locationSearchServiceProvider).initialize();
    } catch (e, s) {
      logger.shout('Error initializing map');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      toggleBottomSheet();
      if (kReleaseMode) {
        showWelcomeBackDialog();
      } else {
        logger.shout("Showing welcome back dialog is disabled in debug mode");
      }
    });
    Future(
      () async {
        ref.read(saltStrongLayerControllerProvider.notifier).initLayers();
        ref.read(saltStrongLayerControllerProvider.notifier).moveToInitialPosition();
        final locationPermissionGranted = await ref
            .read(locationSearchControllerProvider.notifier)
            .centerOnUsersLocation(firstEnter: true);
        if (!locationPermissionGranted) {
          ref
              .read(locationSearchControllerProvider.notifier)
              .showSnackbarIfLocationPermissionDenied(context);
        }
      },
    );
  }

  void showWelcomeBackDialog() {
    showDialog(
      context: context,
      builder: (context) => const WelcomeBackDialog(userName: 'userName'),
      barrierColor: Colors.transparent,
      barrierDismissible: true,
    );
  }

  void toggleBottomSheet() {
    setState(() {
      isBottomSheetOpen = !isBottomSheetOpen;
    });
  }

  void enableLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  void disableLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final smartTidesGraphIndex = ref.watch(smartTidesTabBarViewIndex);
    final defaultTabCtrIndex = ref.watch(defaultTabCtrlIndex);
    (smartTidesGraphIndex == 0 && defaultTabCtrIndex == 0)
        ? enableLandscapeOrientation()
        : disableLandscapeOrientation();
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async => false,
          child: OrientationBuilder(
            builder: (context, orientation) => Scaffold(
              resizeToAvoidBottomInset: false,
              // This is a workaround that makes snack bars appear _above_
              // the bottom sheet. Floating snackbars are shown above FABs,
              // so we just create an invisible, zero-size FAB here.
              floatingActionButton:
                  SizedBox(height: max(0, _bottomSheetHeight - SaltStrongBottomSheet.tabHeight)),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              backgroundColor: Colors.transparent,
              body: Stack(children: [
                // ---------------------- orientation.landscape
                Offstage(
                  //visible: orientation == Orientation.landscape,
                  offstage: orientation == Orientation.portrait,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(graphDataProvider);
                      return state.when(
                          skipLoadingOnReload: true,
                          skipLoadingOnRefresh: true,
                          data: (value) {
                            return LandscapeOrientationGraph(
                              barsData: value.barsData,
                              lineGraphData: value.lineGraphData,
                              maximumsY: value.maximumsY,
                              maxDateData: value.dailyStrikeScore.length,
                              isLoading: value.isLoadingGraphData,
                            );
                          },
                          error: (err, st) {
                            if (err is NoNearbyTideStationException) {
                              return const Center(
                                child: Text("No nearby Tide Stations"),
                              );
                            }
                            debugPrintStack(stackTrace: st);
                            if (err is DioException) {
                              return Center(
                                child: Text(err.response?.toString() ?? 'Exception occurred'),
                              );
                            }
                            return Center(
                              child: Text("Exception occurred $err"),
                            );
                          },
                          loading: () {
                            return const Center(child: CircularProgressIndicator());
                          });
                    },
                  ),
                ),
                // ---------------------- orientation.portrait
                Offstage(
                  offstage: orientation == Orientation.landscape,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Map Widget

                      Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) {
                          return Column(
                            children: [
                              Expanded(
                                child: FlutterMap(
                                  mapController: ref
                                      .read(saltStrongLayerControllerProvider.notifier)
                                      .mapController,
                                  options: MapOptions(
                                    interactiveFlags: InteractiveFlag.pinchZoom |
                                        InteractiveFlag.drag |
                                        InteractiveFlag.doubleTapZoom |
                                        InteractiveFlag.flingAnimation,
                                    rotationWinGestures:
                                        MultiFingerGesture.pinchMove | MultiFingerGesture.pinchZoom,
                                    minZoom: mapMinZoom.toDouble(),
                                    maxZoom: mapMaxZoom.toDouble(),
                                    onTap: (pos, latlng) {
                                      ref
                                          .read(saltStrongLayerControllerProvider.notifier)
                                          .handleMapTap(latlng, context);
                                    },
                                    onPositionChanged: (position, gesture) {
                                      if (position.center != null) {
                                        ref
                                            .read(saltStrongLayerControllerProvider.notifier)
                                            .updatePosition(
                                              MapPos(
                                                x: position.center!.latitude,
                                                y: position.center!.longitude,
                                                z: position.zoom ?? 0,
                                              ),
                                            );
                                      }
                                    },
                                  ),
                                  nonRotatedChildren: const [
                                    TranslucentPointer(child: MainMapCrosshair())
                                  ],
                                  children: [
                                    ...ref.watch(allLayersProvider).map(
                                      (e) {
                                        if (e.isTranslucent) {
                                          return TranslucentPointer(
                                            child: LayerWrapperWidget(layerWrapper: e),
                                          );
                                        }

                                        return LayerWrapperWidget(layerWrapper: e);
                                      },
                                    ).toList(),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isBottomSheetOpen
                                    ? SaltStrongBottomSheet.height - SaltStrongBottomSheet.tabHeight
                                    : 0,
                              ),
                            ],
                          );
                        },
                      ),

                      Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainerWithCallback(
                            expandedHeight: SaltStrongBottomSheet.height,
                            callback: (double currentHeight) {
                              setState(() {
                                _bottomSheetHeight = currentHeight;
                              });
                            },
                            visible: isBottomSheetOpen,
                            child: const SaltStrongBottomSheet(),
                          )),
                      Positioned(
                          key: ValueKey(_bottomSheetHeight),
                          bottom: _bottomSheetHeight,
                          child: buildMapControls()),
                      Positioned(
                        left: 0,
                        bottom: isBottomSheetOpen ? SaltStrongBottomSheet.height + 100 : null,
                        child: const SmartSpotLegend(),
                      ),
                      // Debug Info
                      // const DebugInfo(),
                      // Search
                      const LoadingIndicator(),
                      const SearchWidget(),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMapControls() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BottomSheet button
          MapButton(
            isRightBorderRounded: true,
            onPressed: toggleBottomSheet,
            child: SvgPicture.asset(
              isBottomSheetOpen ? Assets.icons.mapToggleDown.path : Assets.icons.mapToggleUp.path,
              height: 24.h,
              width: 24.w,
            ),
          ),

          // Zoom In button
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MapButton(
                onPressed: () => ref
                    .read(
                      saltStrongLayerControllerProvider.notifier,
                    )
                    .zoomIn(),
                isLeftBorderRounded: true,
                child: Assets.icons.zoomIn.svg(),
              ),
              SizedBox(
                height: 8.h,
              ),
              // Zoom Out button
              MapButton(
                onPressed: () => ref
                    .read(
                      saltStrongLayerControllerProvider.notifier,
                    )
                    .zoomOut(),
                isLeftBorderRounded: true,
                child: Assets.icons.zoomOut.svg(),
              ),
              SizedBox(
                height: 8.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingIndicator extends ConsumerWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    if (isLoading) {
      return SafeArea(
          top: true,
          child: Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()));
    }
    return SizedBox.shrink();
  }
}

class MainMapCrosshair extends StatelessWidget {
  const MainMapCrosshair({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Assets.icons.crossHairs.image(width: 20));
  }
}

// ignore: non_constant_identifier_names
final EXTENT = [-math.pi * 6378137, math.pi * 6378137];

String xyzToBounds(int x, int y, int z, mode) {
  var tileSize = (EXTENT[1] * 2) / math.pow(2, z);

  if (mode == "1024") {
    tileSize = tileSize * 4;
  }

  var minx = EXTENT[0] + x * tileSize;
  var maxx = EXTENT[0] + (x + 1) * tileSize;

  var miny = EXTENT[1] - (y + 1) * tileSize;
  var maxy = EXTENT[1] - y * tileSize;

  return '$minx,$miny,$maxx,$maxy';
}

class AnimatedContainerWithCallback extends StatefulWidget {
  final bool visible;
  final double expandedHeight;
  final Function(double currentHeight) callback;
  final Widget child;

  @override
  State<AnimatedContainerWithCallback> createState() => _AnimatedContainerWithCallbackState();

  const AnimatedContainerWithCallback({
    required this.visible,
    required this.expandedHeight,
    required this.callback,
    required this.child,
  });
}

class _AnimatedContainerWithCallbackState extends State<AnimatedContainerWithCallback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    if (widget.visible) {
      _controller.forward();
    }
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    )..addListener(() {
        _callback();
      });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedContainerWithCallback oldWidget) {
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _callback() {
    widget.callback(_animation.value * widget.expandedHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: _animation.value * widget.expandedHeight,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
