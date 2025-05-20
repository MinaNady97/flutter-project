import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = 16.0; // Left padding
    final double y =
        scaffoldGeometry.scaffoldSize.height - 125.0; // Higher position
    return Offset(x, y);
  }
}

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuickStart(),
                      const SizedBox(height: 24),
                      _buildScheduledWorkouts(),
                      const SizedBox(height: 24),
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                      _buildEquipmentSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkoutDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Home Workout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay fit with personalized workout routines',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Start',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildWorkoutCard(
              'Strength',
              Icons.fitness_center,
              Colors.orange,
            ),
            _buildWorkoutCard(
              'Cardio',
              Icons.directions_run,
              Colors.red,
            ),
            _buildWorkoutCard(
              'Flexibility',
              Icons.self_improvement,
              Colors.green,
            ),
            _buildWorkoutCard(
              'HIIT',
              Icons.timer,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showWorkoutDetails(title),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Workouts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.fitness_center, color: Colors.white),
            ),
            title: const Text('Upper Body Strength'),
            subtitle: const Text('Today, 6:00 PM'),
            trailing: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Progress',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Weekly Goal: 5/7 workouts completed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('View Detailed Progress'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Equipment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildEquipmentChip('Dumbbells'),
            _buildEquipmentChip('Resistance Bands'),
            _buildEquipmentChip('Yoga Mat'),
            _buildEquipmentChip('Jump Rope'),
          ],
        ),
      ],
    );
  }

  Widget _buildEquipmentChip(String label) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.check, size: 16),
      backgroundColor: Colors.blue.withOpacity(0.1),
    );
  }

  void _showWorkoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('New Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Workout Type',
                border: OutlineInputBorder(),
              ),
              items: ['Strength', 'Cardio', 'Flexibility', 'HIIT']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement workout scheduling
              Get.back();
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(String title) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Workout Details'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Start workout
                Get.back();
              },
              child: const Text('Start Workout'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
