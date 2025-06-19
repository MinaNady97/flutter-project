import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/controllers/home_controller.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: Container(
                      height: 0,
                      color: const Color(0xFF2C3A55),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                  ),
                  Positioned(
                    top: 140,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 54,
                          backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/women/44.jpg'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _ProfileInfo(
                              label: 'Name',
                              value: homeController.username.value)),
                          SizedBox(height: 12),
                          _ProfileInfo(
                              label: 'Date of birth', value: 'Mar 25, 2006'),
                          SizedBox(height: 12),
                          _ProfileInfo(
                              label: 'phone', value: '(+91) 956232134'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _ProfileInfo(
                              label: 'Email',
                              value:
                                  '${homeController.username.value}@home.com')),
                          SizedBox(height: 12),
                          _ProfileInfo(
                            label: 'Address',
                            value:
                                '99, Haji Abudakar Chawl,\nDharavi Cross Rd., Kutti Wadi, Dharavi,\nMaharashtra',
                            isAddress: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 24),
              // const Text(
              //   'more info',
              //   style: TextStyle(
              //       color: Color(0xFF2C3A55), fontWeight: FontWeight.w500),
              // ),
              // const Icon(Icons.keyboard_arrow_down_rounded,
              //     color: Color(0xFF2C3A55), size: 32),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit User Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                              text: homeController.userId.value)
                            ..selection = TextSelection.collapsed(
                                offset: homeController.userId.value.length),
                          onChanged: (val) => homeController.setUserId(val),
                        )),
                    const SizedBox(height: 12),
                    Obx(() => TextField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                              text: homeController.username.value)
                            ..selection = TextSelection.collapsed(
                                offset: homeController.username.value.length),
                          onChanged: (val) => homeController.setUsername(val),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3A55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon:
                            const Icon(Icons.logout, color: Color(0xFFC30606)),
                        label: const Text('LogOut',
                            style: TextStyle(color: Color(0xFFC30606))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFC30606), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool isAddress;
  const _ProfileInfo(
      {required this.label, required this.value, this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C3A55),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF2C3A55).withOpacity(0.85),
            fontWeight: isAddress ? FontWeight.w400 : FontWeight.w500,
            fontSize: isAddress ? 13 : 15,
            height: isAddress ? 1.3 : 1.1,
          ),
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
