import 'package:flutter/material.dart';

class UserNeedsCancelSubscriptionPopUp extends StatelessWidget {
  Future<T?> show<T>(context) {
    return showDialog<T>(
      context: context,
      builder: (context) => const UserNeedsCancelSubscriptionPopUp(),
      barrierColor: Colors.transparent,
    );
  }

   const UserNeedsCancelSubscriptionPopUp({super.key});

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
          key: key,
          insetPadding: const EdgeInsets.all(8),
          child: const SizedBox(
            width: 224,
            height: 180,
            child: Center(
              child: Text(
                'You have an active subscription. Before deleting your account, please cancel your ongoing subscription',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


