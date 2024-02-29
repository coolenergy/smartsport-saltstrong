import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/services/markers/markers_service.dart';
import 'package:salt_strong_poc/playground/services/storage/storage_service.dart';
import 'package:salt_strong_poc/playground/services/user/user_service.dart';

import '../../../../auth/registration/email_provider.dart';

sealed class SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

class SplashError extends SplashState {
  final String message;

  SplashError(this.message);
}

final splashControllerProvider = NotifierProvider<SplashController, SplashState>(() {
  return SplashController();
});

class SplashController extends Notifier<SplashState> {
  SplashController();

  @override
  SplashState build() {

    return SplashLoading();
  }

  void load() async {
    state = SplashLoading();

    final localStorage = ref.read(storageServiceProvider);
    await localStorage.initialize();

    try {
       await ref.read(userServiceProvider).retryLogin( );
      await warmupProviders();
      state = SplashLoaded();
    } catch (e) {
      await ref.read(userServiceProvider).clearLogin();
      state = SplashError(e.toString());
    }
  }

  Future<Object> warmupProviders() async {
    return Future.wait([
      // ref.read(communitySpotLoaderProvider.future),
    ]);
  }
}
