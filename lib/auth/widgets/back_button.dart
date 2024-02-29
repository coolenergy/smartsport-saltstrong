import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SaltStrongBackButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  // ignore: use_key_in_widget_constructors
  const SaltStrongBackButton({this.color = Colors.white, this.onTap});

  void _defaultOnTap(BuildContext context) => (context).pop();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _defaultOnTap(context),
      child: Row(
        children: [
          Icon(Icons.chevron_left, color: color),
          Text('Back',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
