import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/location_search_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/map.dart';

import '../../../../gen/assets.gen.dart';

class SearchPopup extends StatefulWidget {
  Future<T?> show<T>(context) {
    return showDialog<T>(
      context: context,
      builder: (context) => this,
    );
  }

  const SearchPopup({super.key});

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  bool showRecents = false;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      // Removed the padding
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///
          /// MAIN CONTENT
          ///
          Flexible(
            child: Container(
              width: 342, // Set the width for the container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 1, color: SaltStrongColors.greyStroke),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///
                      /// MAP WITH CLOSE ICON
                      ///
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: IgnorePointer(
                                ignoring: true,
                                child: FlutterMap(
                                  nonRotatedChildren: [Center(child: Assets.icons.crossHairs.image(width: 20))],
                                  mapController: ref //
                                      .read(locationSearchControllerProvider.notifier)
                                      .searchMapController,
                                  options: MapOptions(
                                    center: ref.read(saltStrongLayerControllerProvider).lastSearchLocation?.latLng,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.google.com/vt?lyrs=s,h&x={x}&y={y}&z={z}',
                                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                                      userAgentPackageName: 'com.example.app',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  topRight: Radius.circular(16),
                                ),
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: const CloseButton(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ///
                      /// SEARCH TEXT FIELD
                      ///
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                        child: TextField(
                          style: TextStyle(fontSize: 20.sp),
                          controller: searchController,
                          cursorColor: SaltStrongColors.primaryBlue,
                          onChanged: ref //
                              .read(locationSearchControllerProvider.notifier)
                              .search,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: SaltStrongColors.primaryBlue),
                            ),
                            hintText: "Search",
                            focusColor: SaltStrongColors.primaryBlue,
                            fillColor: SaltStrongColors.primaryBlue,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Assets.icons.searchIcon.svg(),
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// PLACE SUGGESTIONS AND RECENT RESULTS
                      ///
                      Flexible(
                        child: ref //
                            .watch(locationSearchControllerProvider)
                            .when(
                              data: (resp) {
                                // search locations to be displayed as an option
                                // to select whether google prediction or recent

                                // not allowing duplicates
                                final locations = <SearchLocation>{};

                                // including google predictions to show
                                locations.addAll(resp.results);

                                // including recent locations
                                if (showRecents) {
                                  final recents = ref //
                                      .read(locationSearchControllerProvider)
                                      .value!
                                      .recents;

                                  locations.addAll(recents);
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (locations.isNotEmpty)
                                      Divider(
                                        thickness: 1,
                                        color: SaltStrongColors.black,
                                        height: 8.h,
                                      ),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: SaltStrongColors.searchPopupGradient,
                                        ),
                                        child: CupertinoScrollbar(
                                          thumbVisibility: true,
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: locations.length,
                                            padding: EdgeInsets.zero,
                                            separatorBuilder: (_, __) => const Divider(
                                              height: 0,
                                              thickness: 1.5,
                                            ),
                                            itemBuilder: (context, index) {
                                              final location = locations.toList().elementAt(index);
                                              return ListTile(
                                                // on suggested location selected
                                                onTap: () {
                                                  // setting selected location to text field
                                                  searchController
                                                    ..text = location.toString()
                                                    ..selection = TextSelection.collapsed(
                                                      offset: searchController.text.length,
                                                    );

                                                  ref
                                                      .read(locationSearchControllerProvider.notifier)
                                                      .centerMapOnSearchLocation(location);

                                                  ref.read(tempSearchLocation.notifier).state = location;
                                                },
                                                title: Text(
                                                  location.toString(),
                                                  //location.name,
                                                  style: TextStyle(fontSize: 14.sp),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, s) => Text(e.toString()),
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          ///
          /// SHOW RECENTS BUTTON
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () {
                setState(() {
                  showRecents = !showRecents;
                });
              },
              child: Text(
                showRecents ? 'Hide Recent Search' : 'Show Recent Search',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          ///
          /// CENTER ON NEW LOCATION
          ///
          ///
          Consumer(
            builder: (context, ref, child) => InkWell(
              onTap: () {
                Navigator.of(context).pop();
                final newLocation = ref.watch(tempSearchLocation);

                if (newLocation != null) {
                  ref.read(locationSearchControllerProvider.notifier).addRecentSearchLocation(newLocation);

                  ref //
                      .read(saltStrongLayerControllerProvider.notifier)
                      .updateSearchLocation(newLocation);
                }

                final lastLocation = ref //
                    .read(saltStrongLayerControllerProvider)
                    .lastSearchLocation!;

                ref //
                    .read(saltStrongLayerControllerProvider.notifier)
                    .centerOnSearchLocation(lastLocation);
              },
              child: Ink(
                height: 42,
                width: 342,
                decoration: const BoxDecoration(
                  color: SaltStrongColors.btnRed,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Center on New Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that is invisible for its parent during hit testing, but still
/// allows its subtree to receive pointer events
///
/// See also:
///
///  * [IgnorePointer], which is also invisible for its parent during hit
///    testing, but does not allow its subtree to receive pointer events.
///  * [AbsorbPointer], which is visible during hit testing, but prevents its
///    subtree from receiving pointer event. The opposite of this widget.
class TranslucentPointer extends SingleChildRenderObjectWidget {
  /// Creates a widget that is invisible for its parent during hit testing, but
  /// still allows its subtree to receive pointer events
  const TranslucentPointer({
    super.key,
    this.translucent = true,
    super.child,
  });

  /// Whether this widget is invisible to its parent during hit testing.
  ///
  /// Regardless of whether this render object is invisible to its parent during
  /// hit testing, it will still consume space during layout and be visible
  /// during painting.
  final bool translucent;

  @override
  RenderTranslucentPointer createRenderObject(BuildContext context) =>
      RenderTranslucentPointer(translucent: translucent);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTranslucentPointer renderObject,
  ) =>
      renderObject.translucent = translucent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('translucent', translucent));
  }
}

/// A render object that is invisible to its parent during hit testing.
///
/// When [translucent] is true, this render object allows its subtree to receive
/// pointer events, whilst also not terminating hit testing at itself. It still
/// consumes space during layout and paints its child as usual. It just prevents
/// its children from being the termination of located events, because its render
/// object returns true from [hitTest].
///
/// See also:
///
///  * [RenderIgnorePointer], removing the subtree from considering entirely for
///    the purposes of hit testing.
///  * [RenderAbsorbPointer], which takes the pointer events but prevents any
///    nodes in the subtree from seeing them.
class RenderTranslucentPointer extends RenderProxyBox {
  /// Creates a render object that is invisible to its parent during hit testing
  RenderTranslucentPointer({
    RenderBox? child,
    bool translucent = true,
  })  : _translucent = translucent,
        super(child);

  /// Whether this widget is invisible to its parent during hit testing.
  ///
  /// Regardless of whether this render object is invisible to its parent during
  /// hit testing, it will still consume space during layout and be visible
  /// during painting.
  bool get translucent => _translucent;
  bool _translucent;
  set translucent(bool value) {
    if (value == _translucent) return;
    _translucent = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final hit = super.hitTest(result, position: position);
    return !translucent && hit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('translucent', translucent));
  }
}
