import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_option.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layers_widgets/slider_track_shape.dart';

import '../../../../../gen/assets.gen.dart';
import 'custom_list_tile.dart';

class TransparencyPopUp extends StatefulWidget {
  final String selectedLayerTitle;
  final Widget selectedLayerImage;
  final ValueChanged<double> onTransparencyChanged;
  final List<LayerOption> options;
  final Function(LayerOption option) onOptionSelected;
  final double initialTransparency;
  final LayerOption? initialOption;

  const TransparencyPopUp({
    Key? key,
    required this.selectedLayerTitle,
    required this.initialTransparency,
    required this.selectedLayerImage,
    required this.onTransparencyChanged,
    required this.options,
    required this.initialOption,
    required this.onOptionSelected,
  }) : super(key: key);

  Future<T?> show<T>(BuildContext context) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => this,
    );
  }

  @override
  State<TransparencyPopUp> createState() => _TransparencyPopUpState();
}

class _TransparencyPopUpState extends State<TransparencyPopUp> {
  late double _transparency = widget.initialTransparency; // initial transparency
  late LayerOption? _selectedOption = widget.initialOption;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          gradient: SaltStrongColors.smartTideFilterGradient,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.layerTransparency.svg(),
                    SizedBox(width: 16.w),
                    const Text("Layer Transparency"),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    iconSize: 24,
                    icon: Assets.icons.close.svg(),
                    onPressed: () {
                      Navigator.of(context).pop(_transparency);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 9.h),
              child: Divider(
                color: SaltStrongColors.black,
                thickness: 1,
                height: 31.h,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: widget.selectedLayerImage,
                ),
                SizedBox(width: 16.w),
                Text(
                  widget.selectedLayerTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                width: 74.w,
                height: 40.h,
                decoration: BoxDecoration(
                    color: SaltStrongColors.greyFieldBackground,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.r)),
                child: Center(
                  child: Text(
                    '${(_transparency * 100).toInt()}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: GradientRectSliderTrackShape(
                  gradient: const LinearGradient(
                    begin: Alignment(-1.2, 0.0),
                    end: Alignment(0.6, 0.0),
                    colors: <Color>[SaltStrongColors.sliderInactive, SaltStrongColors.primaryBlue],
                  ),
                ),
                thumbShape: const ColoredThumbSliderShape(
                    thumbRadius: 14.0,
                    innerColor: SaltStrongColors.sliderInactive,
                    thumbColor: SaltStrongColors.primaryBlue),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Slider(
                  value: _transparency,
                  onChanged: (double value) {
                    setState(() {
                      _transparency = value;
                    });
                    widget.onTransparencyChanged(value);
                  },
                ),
              ),
            ),
            SizedBox(
              height: 24.h,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Wrap(
                runSpacing: 12,
                spacing: 12,
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.min,
                children: widget.options
                    .map(
                      (e) => CustomListTile(
                        paddingLeft: 0,
                        pad: false,
                        title: e.title,
                        isSelected: _selectedOption == e,
                        onSelected: (_) {
                          widget.onOptionSelected(e);
                          setState(() {
                            _selectedOption = e;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
