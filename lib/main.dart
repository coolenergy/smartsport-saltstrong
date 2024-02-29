import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/services/in_app_purchase/in_app_purchase_service.dart';
import 'package:salt_strong_poc/routing/router.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

void main() async {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load();
  InAppPurchaseService.initializeStoreConfig();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await InAppPurchaseService.configureSDK();
  runApp(const ProviderScope(child: MyApp()));
}

final globalKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ScreenUtilInit(
      designSize: width > 600 ? MediaQuery.of(context).size : const Size(390, 844),
      builder: (_, __) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        // routeInformationParser: router.routeInformationParser,
        // routerDelegate: router.routerDelegate,
        routerConfig: router,
        builder: (context, child) {
          // disable system font scaling
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
              boldText: false,
            ),
            child: child!,
          );
        },
        theme: Theme.of(context).copyWith(
          primaryColor: SaltStrongColors.primaryBlue,
        ),
      ),
    );
  }
}
