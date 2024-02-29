/// This is a popup for Community and Insider spots , it uses getMarkerInfo API
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenericDataPopup extends ConsumerStatefulWidget {
  final String title;
  final Map<String, dynamic> popupInfo;

  Future<void> show(context) {
    print("showing popup");
    return showDialog(
      context: context,
      builder: (context) {
        return this;
      },
    );
  }

  const GenericDataPopup(this.title, this.popupInfo);

  @override
  ConsumerState<GenericDataPopup> createState() => _CommunityInsiderSpotMarkerPopupState();
}

class _CommunityInsiderSpotMarkerPopupState extends ConsumerState<GenericDataPopup> {
  @override
  @override
  Widget build(BuildContext context) {
    final entries = widget.popupInfo.entries.toList();

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
                              widget.title,
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
                Expanded(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final key = entries[index].key;
                            final value = entries[index].value;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: '$key: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '$value'),
                                ]),
                              ),
                            );
                          }),
                    ),
                  ),
                )
              ],
            );
          })),
    );
  }
}
