import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/controllers/WorkoutController.dart';

class WorkoutScreen extends StatelessWidget {
  final WorkoutController controller = Get.put(WorkoutController());

  WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.workoutPlan.isNotEmpty) {
          controller.workoutPlan.clear();
          return false; // Don't pop the route, just clear the plan
        }
        return true; // Pop the route as normal
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AI Workout Planner"),
          actions: [
            if (controller.workoutPlan.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.workoutPlan.clear(),
                tooltip: 'Create New Plan',
              )
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.workoutPlan.isEmpty) _buildQuickStart(),
                      if (controller.workoutPlan.isEmpty)
                        const SizedBox(height: 24),
                      controller.workoutPlan.isEmpty
                          ? _buildForm()
                          : _buildPlan(),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                )),
        ),
      ),
    );
  }

  Widget _buildQuickStart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Plans',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: controller.popularPlans
              .map((plan) => _buildWorkoutCard(
                    plan['title'],
                    plan['icon'],
                    plan['color'],
                    plan['description'],
                    onTap: () => _showPlanDetails(plan),
                  ))
              .toList(),
        ),
        if (controller.savedPlans.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'Saved Plans',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(() => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: controller.savedPlans.map((plan) {
                  return _buildWorkoutCard(
                    plan['title'] ?? 'Saved Plan',
                    Icons.bookmark, // or any icon you prefer
                    Colors.teal, // consistent or dynamic
                    plan['overview'] ?? 'Custom workout plan',
                    onTap: () => _useSavedPlan(plan),
                  );
                }).toList(),
              )),
        ],
        const Text(
          'Get Started',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fill out your fitness profile to generate a personalized workout plan',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Text(
          'Create Your Plan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    String title,
    IconData icon,
    Color color,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 3, // Show up to 3 lines
                overflow: TextOverflow.ellipsis, // Show dots if text overflows
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanDetails(Map<String, dynamic> plan) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan['title'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${plan['duration']} • ${plan['daysPerWeek']} days/week',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                plan['details']['overview'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Workout Days',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(plan['details']['days'].length, (index) {
                final day = plan['details']['days'][index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text(day['title']),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...day['exercises']
                                .map((exercise) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Text('• $exercise'),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.workoutPlan.value = {};
                        controller.workoutPlan.value = plan['details'];
                        Get.back();
                      },
                      child: const Text("Use This Plan"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Obx(() => controller.errorMessage.value.isNotEmpty
            ? Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              )
            : const SizedBox.shrink()),
        _buildTextField("Age", controller.age, TextInputType.number),
        _buildTextField("Weight (kg)", controller.weight, TextInputType.number),
        _buildTextField("Height (cm)", controller.height, TextInputType.number),
        _buildDropdown("Fitness Goal", controller.fitnessGoal, const [
          'Lose Fat',
          'Build Muscle',
          'Maintain',
          'Improve Endurance'
        ]),
        _buildDropdown("Experience Level", controller.experience,
            const ['Beginner', 'Intermediate', 'Advanced']),
        _buildChipsSelector(),
        _buildMultilineField("Injuries/Limitations", controller.limitations),
        const SizedBox(height: 20),
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.generateWorkoutPlan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Generate My AI Plan"),
              ),
            ))
      ],
    );
  }

  Widget _buildPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plan header
        _buildPlanHeader(),

        // Workout days
        const SizedBox(height: 24),
        ...List.generate(controller.workoutPlan['days']?.length ?? 0, (index) {
          final day = controller.workoutPlan['days'][index];
          return _buildWorkoutDayCard(day);
        }),

        // Action buttons
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => controller.workoutPlan.clear(),
                    child: const Text("Create New Plan"))),
            const SizedBox(width: 16),
            if (!controller.isFromPopularPlan())
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _savePlan(),
                  child: const Text("Save Plan"),
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _buildPlanHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.workoutPlan['title'] ?? 'Your Workout Plan',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPlanDetailChip(
              Icons.timer,
              controller.workoutPlan['duration'] ?? '30 minutes',
            ),
            const SizedBox(width: 8),
            _buildPlanDetailChip(
              Icons.bolt,
              '${controller.workoutPlan['intensity']?.toString().capitalizeFirst ?? 'Moderate'} Intensity',
            ),
          ],
        ),
        if (controller.workoutPlan['bmi'] != null) ...[
          const SizedBox(height: 8),
          Text(
            'Your BMI: ${controller.workoutPlan['bmi'].toStringAsFixed(1)}',
            style: TextStyle(
              color: _getBmiColor(controller.workoutPlan['bmi']),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (controller.workoutPlan['overview'] != null)
          Text(
            controller.workoutPlan['overview'],
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildWorkoutDayCard(Map<String, dynamic> day) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          day['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...day['exercises']
                    .map((exercise) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: GestureDetector(
                            onTap: () => _showExerciseDetail(exercise),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(exercise)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Colors.blue[50],
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTextField(
      String label, RxString value, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        keyboardType: keyboardType,
        onChanged: (val) => value.value = val,
      ),
    );
  }

  Widget _buildMultilineField(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignLabelWithHint: true,
        ),
        maxLines: 3,
        onChanged: (val) => value.value = val,
      ),
    );
  }

  Widget _buildDropdown(String label, RxString selected, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: selected.value.isEmpty ? null : selected.value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => selected.value = val ?? '',
      ),
    );
  }

  Widget _buildChipsSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Available Equipment",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.equipmentOptions.map((e) {
                  final isSelected = controller.equipment.contains(e);
                  return FilterChip(
                    label: Text(e),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleEquipment(e),
                    selectedColor: Colors.blue.withOpacity(0.1),
                    checkmarkColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange; // Underweight
    if (bmi >= 18.5 && bmi < 25) return Colors.green; // Normal
    if (bmi >= 25 && bmi < 30) return Colors.orange; // Overweight
    return Colors.red; // Obese
  }

  void _showExerciseDetail(String exercise) {
    Get.dialog(
      AlertDialog(
        title: const Text("Exercise Details"),
        content: SingleChildScrollView(
          child: Text(exercise),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _savePlan() async {
    final isPopular = controller.isFromPopularPlan();

    if (isPopular) {
      Get.snackbar('Notice', 'This plan is already in popular plans.');
      return;
    }

    await controller.saveWorkoutPlan();
    Get.snackbar('Success', 'Workout plan saved!');
  }

  void _useSavedPlan(Map<String, dynamic> plan) {
    controller.workoutPlan.value = Map<String, dynamic>.from(plan);
  }
}
