import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';

class DebugPopup extends ConsumerWidget {
  const DebugPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingMapV = ref.watch(loadingMapProvider);

    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (final entry in loadingMapV.entries) _buildWidget(entry)],
        ),
      ),
    );
  }

  Widget _buildWidget(MapEntry<Object, AsyncValue> entry) {
    return ListTile(
        title: Text(entry.key.toString()),
        subtitle: Text(
          entry.value.when(data: (data) {
            return "Loaded OK";
          }, error: (e, st) {
             debugPrintStack(stackTrace: st);
            if (e is DioException) {
              final data = e.requestOptions.data is FormData
                  ? jsonEncode(Map.fromEntries((e.requestOptions.data as FormData).fields)).toString()
                  : e.requestOptions.data.toString();
              return e.toString() + e.response.toString() + " Requested with data:\n " + data;
            }

            return e.toString();
          }, loading: () {
            return "Loading";
          }),
        ));
  }
}
