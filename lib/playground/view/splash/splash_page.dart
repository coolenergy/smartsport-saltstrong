import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/playground/view/splash/controller/splash_controller.dart';
import 'package:salt_strong_poc/routing/router.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
     Future((){
       ref.read(splashControllerProvider.notifier).load();
     });
    }, const []);

    ref.listen(splashControllerProvider, (previous, next) {
      switch (next) {
        case SplashLoaded():
          GoRouter.of(context).pushReplacement(RoutePaths.home);
          break;
        case SplashError():
          GoRouter.of(context).pushReplacement(RoutePaths.signIn);
          break;
        default:
          break;
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
