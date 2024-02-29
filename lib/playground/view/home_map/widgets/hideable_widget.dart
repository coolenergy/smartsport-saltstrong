import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HideableWidget extends StatefulWidget {
  final Widget child;
  const HideableWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<HideableWidget> createState() => _HideableWidgetState();
}

class _HideableWidgetState extends State<HideableWidget> {
  bool hidden = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hidden) widget.child,
        InkWell(
          onTap: () {
            setState(
              () {
                hidden = !hidden;
              },
            );
          },
          child: Container(
            height: 24,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Icon(
                hidden ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
