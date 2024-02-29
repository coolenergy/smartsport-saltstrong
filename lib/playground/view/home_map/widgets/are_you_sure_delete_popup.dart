import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

class AreYouSureDeletePopUp extends StatelessWidget {
  final Function() onDeletePressed;

  Future<T?> show<T>(context) {
    return showDialog<T>(
      context: context,
      builder: (context) => AreYouSureDeletePopUp(
        onDeletePressed: onDeletePressed,
      ),
      barrierColor: Colors.transparent,
    );
  }

  const AreYouSureDeletePopUp({super.key, required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        Navigator.of(context).pop();
      },
      child: Transform.translate(
        offset: const Offset(0, -160),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          key: key,
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 224,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Are you sure you want to delete your account? All your data will be erased. ' +
                        'You have an active subscription. Before deleting your account, please cancel your ongoing subscription',
                    style: TextStyle(fontWeight: FontWeight.bold),

                    textAlign: TextAlign.center,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: SaltStrongColors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onDeletePressed();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: SaltStrongColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
