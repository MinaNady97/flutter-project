import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'core/constants/routes.dart';
import 'core/services/notification_service.dart';
import 'controllers/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services as permanent services
  Get.put(NotificationService(), permanent: true);
  Get.put(HomeController(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HCI',
      theme: ThemeData(
        primaryColor: AppRoute.primaryColor,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppRoute.primaryColor,
          secondary: AppRoute.secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
            backgroundColor: AppRoute.primaryColor,
            foregroundColor: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppRoute.primaryColor,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(AppRoute.primaryColor),
        ),
      ),
      initialRoute: AppRoute.homepage,
      getPages: routes,
    );
  }
}
