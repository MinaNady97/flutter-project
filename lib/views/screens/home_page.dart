import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hci_flutter/views/screens/workout_screen.dart';
import 'calendar_screen.dart';
import 'sos_screen.dart';
import 'menu_screen.dart';
import '../../core/constants/routes.dart';
import '../../controllers/background_controller.dart';
import '../../controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final BackgroundController _backgroundController = Get.put(
    BackgroundController(),
  );
  late final HomeController _homeController;

  final List<Widget> _screens = [
    CalendarScreen(),
    WorkoutScreen(),
    const MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Get the HomeController that was already initialized in main.dart
    _homeController = Get.find<HomeController>();
    _backgroundController.changeBackground(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_backgroundController.currentBackground.value),
              fit: BoxFit.cover,
            ),
          ),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 50.0,
        items: const <Widget>[
          Icon(Icons.calendar_today, size: 25),
          Icon(Icons.fitness_center, size: 25),
          Icon(Icons.menu, size: 25),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: AppRoute.primaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _backgroundController.changeBackground(index);
        },
        letIndexChange: (index) => true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: 'notification-settings',
          //   onPressed: () {
          //     Get.toNamed('/notification-settings');
          //   },
          //   backgroundColor: Colors.blue,
          //   mini: true,
          //   child: const Icon(Icons.notifications),
          // ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'SosScreen',
            onPressed: () {
              Get.to(() => const SosScreen());
            },
            backgroundColor: Color(0XFFC30606),
            child: const Icon(Icons.warning),
          ),
        ],
      ),
    );
  }
}
