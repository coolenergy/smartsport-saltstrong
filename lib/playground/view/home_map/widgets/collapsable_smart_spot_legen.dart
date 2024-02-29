import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/debug_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';

class SmartSpotLegend extends StatefulWidget {
  const SmartSpotLegend({Key? key}) : super(key: key);

  @override
  State<SmartSpotLegend> createState() => _SmartSpotLegendState();
}

class _SmartSpotLegendState extends State<SmartSpotLegend> {
  bool expanded = false;


  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isEnabled =
            ref.watch(saltStrongLayerControllerProvider).isSmartSpotEnabled;

        return AnimatedContainer(
          transform: Matrix4.translationValues(expanded ? 0 : -23, 0, 0),
          duration: const Duration(milliseconds: 300),
          child: !isEnabled
              ? const SizedBox()
              : InkWell(
                  onLongPress: () {
                    if(false)
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const DebugPopup();
                        });
                  },
                  onTap: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: expanded
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 4.0, top: 4),
                                  child: SizedBox(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        "Smart Spot Key",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        CollapsableColor(
                          color: const Color(0xFFFF005B),
                          text: "Hot",
                          isExpanded: expanded,
                        ),
                        const SizedBox(height: 6),
                        CollapsableColor(
                          color: const Color(0xFFFFDF39),
                          text: "Great",
                          isExpanded: expanded,
                        ),
                        const SizedBox(height: 6),
                        CollapsableColor(
                          color: const Color(0xFFF3AEFF),
                          text: "Good",
                          isExpanded: expanded,
                        ),
                        const SizedBox(height: 6),
                        CollapsableColor(
                          color: const Color(0xFF6527A4),
                          text: "Fair",
                          isExpanded: expanded,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class CollapsableColor extends StatelessWidget {
  final Color color;
  final String text;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: isExpanded
              ? SizedBox(
                  width: 40,
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, height: 1),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 4,
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: use_key_in_widget_constructors
  const CollapsableColor({
    required this.color,
    required this.text,
    required this.isExpanded,
  });
}
