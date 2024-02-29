import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/http/dio.dart';
import '../controller/customized_providers.dart';
import 'hideable_widget.dart';

class DebugInfo extends ConsumerWidget {
  const DebugInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Positioned(
      top: 80.h,
      right: 10.w,
      left: 10.w,
      child: SafeArea(
        top: true,
        child: HideableWidget(
          child: Container(
            margin: EdgeInsets.all(8.r),
            padding: EdgeInsets.all(8.r),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  "Selected UTC Time ${ref.watch(selectedDateTimeProvider).toUtc()}",
                ),
                SizedBox(
                  height: 8.h,
                ),
                Consumer(builder: (context, ref, c) {
                  final pos = ref.watch(realtimeSyncMapPosProvider);
                  return Text("Current pos $pos");
                }),
                if (kDebugMode)
                  Consumer(
                    builder: (context, ref, c) {
                      final reqs = ref.watch(currentRequestsProvider);
                      return Column(
                        children: [
                          ...reqs.values.map(
                            (e) => Row(
                              children: [
                                Text("Requesting ${e.path}"),
                                SizedBox(
                                  width: 10.w,
                                ),
                                SizedBox(
                                  height: 10.h,
                                  width: 10.w,
                                  child: const CircularProgressIndicator(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
