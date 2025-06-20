import 'package:get/get.dart';
import 'views/screens/home_page.dart';
import 'core/constants/routes.dart';

List<GetPage<dynamic>> routes = [
  GetPage(name: AppRoute.homepage, page: () => const HomePage()),
  
  // GetPage(
  //   name: "/",
  //   page: () => OnboardingScreen(),
  //   middlewares: [MyMiddleWare()],
  // ),
  // GetPage(
  //   name: AppRoute.onboarding,
  //   page: () => OnboardingScreen(),
  // ),
];
