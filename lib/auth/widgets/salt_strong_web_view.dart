import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract class Links {
  static const privacyPolicy = 'https://www.saltstrong.com/privacy-policy/';
  static const termsOfUse = 'https://www.saltstrong.com/terms-and-conditions/';
}

abstract class SaltStrongWebView {
  static Future<WebViewController> init(String uri) async {
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted).then(
          (_) => controller.loadRequest(Uri.parse(uri)),
        );
    return controller;
  }

  static Future<void> open(
    WebViewController controller,
    BuildContext context,
  ) async {
    try {
      await showGeneralDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(0.6),
        barrierDismissible: false,
        barrierLabel: 'Get Started',
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => _SaltStrongWebViewPopup(controller),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class _SaltStrongWebViewPopup extends StatelessWidget {
  final WebViewController _controller;

  const _SaltStrongWebViewPopup(this._controller);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Colors.white,
      child: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 8),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: Navigator.of(context).pop,
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
