import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import 'back_button.dart';

class SaltStrongGreeting extends StatelessWidget {
  final String title;
  final Widget backButton;

  static final imageHeight = 200.h;

  // ignore: use_key_in_widget_constructors
  const SaltStrongGreeting(
    this.title, {
    this.backButton = const SaltStrongBackButton(),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Assets.images.authGreeting.image(fit: BoxFit.fill),
          Assets.images.oceanShadow.image(fit: BoxFit.fill),
          Column(children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: backButton,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            const Spacer(),
          ]),
        ],
      ),
    );
  }
}
