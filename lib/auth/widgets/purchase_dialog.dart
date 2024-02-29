import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PurchaseDialog extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;

  const PurchaseDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: Navigator.of(context).pop,
            child: Text(buttonText[0].toUpperCase() + buttonText.substring(1).toLowerCase()),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
