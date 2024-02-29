import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salt_strong_poc/playground/view/home_map/map.dart';
import 'package:salt_strong_poc/playground/view/splash/splash_page.dart';

import '../auth/create_new_password/create_new_password_page.dart';
import '../auth/forgot_password/forgot_password_page.dart';
import '../auth/registration/registration_page.dart';
import '../auth/sign_in/sign_in_page.dart';

import '../auth/welcome_back/welcome_back_page.dart';

class RoutePaths {
  static const splash = '/';
  static const home = '/home';
  static const signIn = '/signIn';
  static const welcomeBack = '/welcomeBack';
  static const registration = '/registration';
  static const forgotPassword = '/forgot_password';
  static const createNewPassword = '/create_new_password';
}

final GoRouter router = GoRouter(
  initialLocation: RoutePaths.splash,
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    SimpleNavigationObserver()
  ],
  routes: <RouteBase>[
    GoRoute(
        path: RoutePaths.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.home,
        builder: (BuildContext context, GoRouterState state) {
          return const MapHomePage();
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.createNewPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const CreateNewPasswordPage();
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.signIn,
        builder: (BuildContext context, GoRouterState state) {
          return const SignInPage();
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.welcomeBack,
        builder: (BuildContext context, GoRouterState state) {
          return WelcomeBackPage(
              pushedBecauseOfException: state.extra as Exception?);
        },
        routes: const []),
    GoRoute(
        path: RoutePaths.registration,
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrationPage();
        },
        routes: const []),
  ],
);

class SimpleNavigationObserver extends RouteObserver {
  static String? currentRoute = RoutePaths.splash;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) currentRoute = route.settings.name;
    super.didPush(route, previousRoute);
  }
}
