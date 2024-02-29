import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';

import '../../../../gen/assets.gen.dart';

class LayersChangedSnackbar extends ConsumerWidget {
  const LayersChangedSnackbar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedDate = ref.watch(selectedDateTimeProvider);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: SaltStrongColors.greyStroke.withOpacity(0.9)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // stretch to fill the width
        children: [
          Container(
            color: SaltStrongColors.seaFoam.withOpacity(0.9), // top half light blue color
            padding: const EdgeInsets.symmetric(vertical: 12), // add vertical padding
            child: Center(
              child: Text(
                'Smart Tides changed to ${DateFormat('MMM d, y').format(selectedDate)}',
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.black, // black color text
                  fontSize: 12, // font size 12
                  fontFamily: 'Inter', // Inter font
                  fontWeight: FontWeight.normal,
                  height: 1.5, // line height (flutter uses a ratio for line height)
                ),
                textAlign: TextAlign.center, // text align center
              ),
            ),
          ),
          Container(
            color: SaltStrongColors.primaryBlue.withOpacity(0.6), // bottom half darker blue color
            padding: const EdgeInsets.symmetric(vertical: 12), // add vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.back.svg(),
                const SizedBox(width: 8),
                const Text(
                  'Return',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white, // white color text
                    fontSize: 12, // font size 12
                    fontFamily: 'Inter', // Inter font
                    fontWeight: FontWeight.normal,
                    height: 1.5, // line height (flutter uses a ratio for line height)
                  ),
                  textAlign: TextAlign.center, // text align center
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
