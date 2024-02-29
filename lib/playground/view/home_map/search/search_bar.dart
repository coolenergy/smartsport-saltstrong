import 'dart:ui';

import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';

import '../../../../gen/assets.gen.dart';
import '../../../constants/colors.dart';
import '../../../services/markers/customized_providers.dart';
import '../controller/layer_controller.dart';
import '../controller/location_search_controller.dart';
import '../widgets/hideable_widget.dart';
import '../widgets/salt_strong_snackbar.dart';
import '../widgets/search_popup.dart';
import 'package:location/location.dart';

class SearchWidget extends ConsumerWidget {
  const SearchWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, ref) {
    final location = ref.watch(
      saltStrongLayerControllerProvider.select(
        (value) => value.lastSearchLocation,
      ),
    );
    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: HideableWidget(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              width: MediaQuery.of(context).size.width - 80.w,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 42.h,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 4,
                          sigmaY: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => const SearchPopup().show(context).then((value) {
                                  // if SearchPopup is dismissed by tapping on barrier, delete tempSearchLocation
                                  if (value == null) {
                                    ref.read(tempSearchLocation.notifier).state = null;
                                  }
                                }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 12.w,
                                    ),
                                    Assets.icons.searchIcon.svg(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.w,
                                    ),
                                    Expanded(
                                      child: Text(
                                        location?.toString() ?? "Press search",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    // here
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Future(
                                  () async {
                                    final locationPermissionGranted = await ref
                                        .read(locationSearchControllerProvider.notifier)
                                        .centerOnUsersLocation(firstEnter: true);
                                    if (!locationPermissionGranted) {
                                      ref.read(locationSearchControllerProvider.notifier).showSnackbarIfLocationPermissionDenied(context);
                                    }
                                  },
                                );
                              },
                              child: Container(
                                height: 42.h,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.white,
                                      width: 1.0.w,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0.w,
                                  ),
                                  child: Assets.icons.location.svg(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const ClosestTideStationWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}

class ClosestTideStationWidget extends StatelessWidget {
  const ClosestTideStationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, c) {
      final closest = ref.watch(closestStationProvider);

      return Container(
        // height: 32.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          border: Border(
            top: BorderSide(
              width: 1.w,
              color: SaltStrongColors.greyStroke,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Row(
            children: [
              SizedBox(
                width: 6.w,
              ),
              Assets.icons.tideStations.svg(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
