import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';
import 'core/constants/routes.dart';

void main() {
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
          foregroundColor: Colors.white,
        ),
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
