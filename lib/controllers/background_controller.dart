import 'package:get/get.dart';

class BackgroundController extends GetxController {
  final RxString currentBackground = 'assets/images/clouds1.jpg'.obs;

  void changeBackground(int index) {
    // Ensure index is between 1 and 10
    int imageNumber = (index % 10) + 1;
    currentBackground.value = 'assets/images/clouds$imageNumber.jpg';
  }
}
