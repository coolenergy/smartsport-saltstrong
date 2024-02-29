/// This is a popup for Community and Insider spots , it uses getMarkerInfo API
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/marker_info.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/marker_info_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommunityInsiderSpotMarkerPopup extends ConsumerStatefulWidget {
  final MarkerInfo markerInfo;

  Future<void> show(context) {
    print("showing popup");
    return showDialog(
      context: context,
      builder: (context) {
        return this;
      },
    );
  }

  const CommunityInsiderSpotMarkerPopup(this.markerInfo);

  @override
  ConsumerState<CommunityInsiderSpotMarkerPopup> createState() => _CommunityInsiderSpotMarkerPopupState();
}

class _CommunityInsiderSpotMarkerPopupState extends ConsumerState<CommunityInsiderSpotMarkerPopup> {
  late InAppWebViewController webViewController;

  @override
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      color: Colors.transparent,
      child: Dialog(
          insetPadding: const EdgeInsets.all(24),
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
                              widget.markerInfo.title ??
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
                  height: 600,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              '${widget.markerInfo.point.latitude.toStringAsFixed(3)}, ${widget.markerInfo.point.longitude.toStringAsFixed(3)}'),
                        ),
                        Row(
                          children: [
                            if (widget.markerInfo.profilePhoto != null)
                              ClipOval(
                                child: CircleAvatar(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.markerInfo.profilePhoto!,
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.markerInfo.username,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(DateFormat.yMMMMd().add_Hm().format(widget.markerInfo.timestamp)),
                              ],
                            ),
                          ],
                        ),
                        if (widget.markerInfo.lureNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text.rich(
                              TextSpan(children: [
                                const TextSpan(
                                  text: 'Lures: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: widget.markerInfo.lureNames),
                              ]),
                            ),
                          ),
                        if (widget.markerInfo.speciesNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text.rich(
                              TextSpan(children: [
                                const TextSpan(
                                  text: 'Species: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: widget.markerInfo.speciesNames),
                              ]),
                            ),
                          ),
                        Flexible(
                          child: InAppWebView(onWebViewCreated: (controller) {
                            webViewController = controller;
                            String data = (widget.markerInfo.content ?? "") + (widget.markerInfo.postText ?? "");
                            webViewController.loadData(
                                data:
                                    '<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>$data');
                          }),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          })),
    );
  }

  @override
  void dispose() {
    webViewController.dispose();

    super.dispose();
  }
}
