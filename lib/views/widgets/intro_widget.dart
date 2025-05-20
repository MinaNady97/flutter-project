import 'package:flutter/material.dart';

class IntroWidget extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final String image;
  final bool skip;
  final VoidCallback onTab;

  const IntroWidget({
    Key? key,
    required this.color,
    required this.title,
    required this.description,
    required this.image,
    required this.skip,
    required this.onTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              skip
                  ? TextButton(
                onPressed: () {
                  // Skip action
                },
                child: const Text(
                  "Skip Now",
                  style: TextStyle(color: Colors.black),
                ),
              )
                  : const SizedBox.shrink(),
              ElevatedButton(
                onPressed: onTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
