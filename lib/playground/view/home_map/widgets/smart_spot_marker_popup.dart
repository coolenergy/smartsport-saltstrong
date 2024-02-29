import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

import '../../../modelsV2/marker_popup_data.dart';

class SmartSpotMarkerPopUp extends StatefulWidget {
  Future<T?> show<T>(context) {
    return showDialog<T>(
      context: context,
      builder: (context) => SmartSpotMarkerPopUp(markerData: markerData),
      barrierColor: Colors.transparent,
    );
  }

  final SmartSpotMarkerPopupData markerData;

  const SmartSpotMarkerPopUp({super.key, required this.markerData});

  @override
  State<SmartSpotMarkerPopUp> createState() => _SmartSpotMarkerPopUpState();
}

class _SmartSpotMarkerPopUpState extends State<SmartSpotMarkerPopUp> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        Navigator.of(context).pop();
      },
      child: Transform.translate(
        offset: const Offset(0, -160),
        child: Dialog(
          key: key,
          insetPadding: const EdgeInsets.all(8),
          // shape: TailShape(tailWidth: 72, tailHeight: 32),
          child: SizedBox(
            width: 224,
            child: Consumer(builder: (context, ref, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(12.0),
                            //   child: Assets.icons.star.svg(),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 44.w),
                              child: Text(
                                widget.markerData.spotName ??
                                    'Default Spot Name', // If spotName is null, 'Default Spot Name' will be used.
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Align(alignment: Alignment.centerRight, child: CloseButton()),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: SaltStrongColors.markerPopupGradient,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //   child: Text(
                            //       '${widget.markerData.latLng.latitude.toStringAsFixed(3)}, ${widget.markerData.latLng.longitude.toStringAsFixed(3)}'),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text.rich(
                                TextSpan(children: [
                                  const TextSpan(
                                    text: 'Performance: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.markerData.spot_grade.capitalize() ??
                                        "", // todo insert performance text here
                                  ),
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Wind:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' ${widget.markerData.winds.map((wind) => wind.name).toList().join(", ")}',
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text.rich(TextSpan(children: [
                                  const TextSpan(
                                    text: 'Tide:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' ${widget.markerData.currentTideName}',
                                  ),
                                ]))),
                            if (widget.markerData.species.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text.rich(
                                  TextSpan(children: [
                                    const TextSpan(
                                      text: 'Expected Species:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' ${widget.markerData.species.join(" \u2981 ")}',
                                    ),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
