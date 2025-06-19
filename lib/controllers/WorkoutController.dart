import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci_flutter/controllers/home_controller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/routes.dart';

class WorkoutController extends GetxController {
  var age = ''.obs;
  var weight = ''.obs;
  var height = ''.obs;
  var fitnessGoal = ''.obs;
  var experience = ''.obs;
  var equipment = <String>[].obs;
  var limitations = ''.obs;
  var isLoading = false.obs;
  var workoutPlan = {}.obs;
  var errorMessage = ''.obs;
  RxList<Map<String, dynamic>> savedPlans = <Map<String, dynamic>>[].obs;
  final homeController = Get.find<HomeController>();

  void toggleEquipment(String item) {
    if (equipment.contains(item)) {
      equipment.remove(item);
    } else {
      equipment.add(item);
    }
  }

  final List<String> equipmentOptions = [
    'Dumbbells',
    'Resistance Bands',
    'Yoga Mat',
    'Jump Rope',
    'Kettlebells',
    'Pull-up Bar',
    'Stability Ball'
  ];

  final List<Map<String, dynamic>> popularPlans = [
    {
      'title': 'Push-Pull-Legs',
      'type': 'Strength',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'description': 'Classic strength training split',
      'duration': '6 weeks',
      'daysPerWeek': 5,
      'details': {
        'overview':
            'The PPL split divides training into pushing movements (chest, shoulders, triceps), pulling movements (back, biceps), and leg days for balanced muscle development.',
        'days': [
          {
            'title': 'Push Day (Chest/Shoulders/Triceps)',
            'exercises': [
              'Bench Press: 4 sets x 6-8 reps',
              'Overhead Press: 3 sets x 8-10 reps',
              'Incline Dumbbell Press: 3 sets x 10-12 reps',
              'Lateral Raises: 3 sets x 12-15 reps',
              'Tricep Dips: 3 sets x 10-12 reps'
            ]
          },
          {
            'title': 'Pull Day (Back/Biceps)',
            'exercises': [
              'Deadlifts: 4 sets x 5 reps',
              'Pull-ups: 3 sets x 8-10 reps',
              'Bent-over Rows: 3 sets x 8-10 reps',
              'Face Pulls: 3 sets x 12-15 reps',
              'Barbell Curls: 3 sets x 10-12 reps'
            ]
          },
          {
            'title': 'Legs Day',
            'exercises': [
              'Squats: 4 sets x 6-8 reps',
              'Romanian Deadlifts: 3 sets x 8-10 reps',
              'Bulgarian Split Squats: 3 sets x 10-12 reps',
              'Leg Curls: 3 sets x 12-15 reps',
              'Calf Raises: 4 sets x 15-20 reps'
            ]
          },
          {
            'title': 'Push Day (Variation)',
            'exercises': [
              'Incline Bench Press: 4 sets x 6-8 reps',
              'Arnold Press: 3 sets x 8-10 reps',
              'Chest Flyes: 3 sets x 10-12 reps',
              'Rear Delt Flyes: 3 sets x 12-15 reps',
              'Skull Crushers: 3 sets x 10-12 reps'
            ]
          },
          {
            'title': 'Pull Day (Variation)',
            'exercises': [
              'T-bar Rows: 4 sets x 6-8 reps',
              'Lat Pulldowns: 3 sets x 8-10 reps',
              'Seated Cable Rows: 3 sets x 10-12 reps',
              'Hammer Curls: 3 sets x 10-12 reps',
              'Preacher Curls: 3 sets x 12-15 reps'
            ]
          }
        ]
      }
    },
    {
      'title': 'Upper/Lower Split',
      'type': 'Strength',
      'icon': Icons.accessibility_new,
      'color': Colors.blue,
      'description': 'Balanced upper/lower body focus',
      'duration': '8 weeks',
      'daysPerWeek': 4,
      'details': {
        'overview':
            'This split alternates between upper and lower body days, allowing for adequate recovery while hitting each muscle group twice per week.',
        'days': [
          {
            'title': 'Upper Body A',
            'exercises': [
              'Bench Press: 4 sets x 6-8 reps',
              'Pull-ups: 3 sets x 8-10 reps',
              'Overhead Press: 3 sets x 8-10 reps',
              'Barbell Rows: 3 sets x 8-10 reps',
              'Bicep Curls: 3 sets x 10-12 reps'
            ]
          },
          {
            'title': 'Lower Body A',
            'exercises': [
              'Squats: 4 sets x 6-8 reps',
              'Romanian Deadlifts: 3 sets x 8-10 reps',
              'Leg Press: 3 sets x 10-12 reps',
              'Leg Curls: 3 sets x 12-15 reps',
              'Calf Raises: 4 sets x 15-20 reps'
            ]
          },
          {
            'title': 'Upper Body B',
            'exercises': [
              'Incline Bench Press: 4 sets x 6-8 reps',
              'Lat Pulldowns: 3 sets x 8-10 reps',
              'Arnold Press: 3 sets x 8-10 reps',
              'Face Pulls: 3 sets x 12-15 reps',
              'Tricep Extensions: 3 sets x 10-12 reps'
            ]
          },
          {
            'title': 'Lower Body B',
            'exercises': [
              'Deadlifts: 4 sets x 5 reps',
              'Front Squats: 3 sets x 6-8 reps',
              'Step-ups: 3 sets x 10-12 reps',
              'Glute Bridges: 3 sets x 12-15 reps',
              'Seated Calf Raises: 4 sets x 15-20 reps'
            ]
          }
        ]
      }
    },
    {
      'title': 'Full Body',
      'type': 'Strength',
      'icon': Icons.accessibility,
      'color': Colors.purple,
      'description': 'Total body workouts',
      'duration': '4 weeks',
      'daysPerWeek': 3,
      'details': {
        'overview':
            'Full body workouts that hit all major muscle groups in each session, ideal for beginners or those with limited time.',
        'days': [
          {
            'title': 'Full Body A',
            'exercises': [
              'Squats: 3 sets x 8-10 reps',
              'Bench Press: 3 sets x 8-10 reps',
              'Bent-over Rows: 3 sets x 8-10 reps',
              'Overhead Press: 3 sets x 8-10 reps',
              'Plank: 3 sets x 30-60 sec'
            ]
          },
          {
            'title': 'Full Body B',
            'exercises': [
              'Deadlifts: 3 sets x 6-8 reps',
              'Pull-ups: 3 sets x 8-10 reps',
              'Incline Dumbbell Press: 3 sets x 10-12 reps',
              'Lunges: 3 sets x 10-12 reps',
              'Russian Twists: 3 sets x 15 reps'
            ]
          },
          {
            'title': 'Full Body C',
            'exercises': [
              'Front Squats: 3 sets x 8-10 reps',
              'Dips: 3 sets x 8-10 reps',
              'Single-arm Rows: 3 sets x 10-12 reps',
              'Bulgarian Split Squats: 3 sets x 10-12 reps',
              'Hanging Leg Raises: 3 sets x 12-15 reps'
            ]
          }
        ]
      }
    },
    {
      'title': 'HIIT Burn',
      'type': 'Cardio',
      'icon': Icons.timer,
      'color': Colors.red,
      'description': 'High intensity interval training',
      'duration': '4 weeks',
      'daysPerWeek': 3,
      'details': {
        'overview':
            'This program alternates between short bursts of intense exercise and brief recovery periods to maximize fat burning and cardiovascular improvement.',
        'days': [
          {
            'title': 'Tabata Day',
            'exercises': [
              'Jump Squats: 20 sec work / 10 sec rest x 8 rounds',
              'Burpees: 20 sec work / 10 sec rest x 8 rounds',
              'Mountain Climbers: 20 sec work / 10 sec rest x 8 rounds',
              'Rest 1 minute between exercises'
            ]
          },
          {
            'title': 'Circuit Day',
            'exercises': [
              '30 sec Jump Rope',
              '30 sec Box Jumps',
              '30 sec Battle Ropes',
              '30 sec Medicine Ball Slams',
              'Repeat circuit 4x with 1 min rest between'
            ]
          },
          {
            'title': 'Endurance Day',
            'exercises': [
              '400m Run',
              '20 Air Squats',
              '20 Push-ups',
              'Repeat 5 rounds for time'
            ]
          }
        ]
      }
    }
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedPlans();
  }

  Future<void> _loadSavedPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('saved_plans');
    if (saved != null) {
      savedPlans.value =
          saved.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
    }
  }

  Future<void> saveWorkoutPlan() async {
    // If already from popular, don't save
    final isPopular = popularPlans
        .any((p) => jsonEncode(p['details']) == jsonEncode(workoutPlan));

    if (isPopular) return;

    final existing = savedPlans
        .where((p) => jsonEncode(p) == jsonEncode(workoutPlan))
        .isNotEmpty;
    if (existing) return;

    if (savedPlans.length >= 2) {
      savedPlans.removeAt(0); // Remove oldest
    }

    savedPlans.add(Map<String, dynamic>.from(workoutPlan));

    final prefs = await SharedPreferences.getInstance();
    final data = savedPlans.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList('saved_plans', data);
  }

  bool isFromPopularPlan() {
    return popularPlans
        .any((p) => jsonEncode(p['details']) == jsonEncode(workoutPlan));
  }

  Future<void> generateWorkoutPlan() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate required fields
      if (age.value.isEmpty ||
          weight.value.isEmpty ||
          height.value.isEmpty ||
          fitnessGoal.value.isEmpty ||
          experience.value.isEmpty) {
        throw Exception('Please fill all required fields');
      }

      final payload = {
        'user_id': homeController.userId.value,
        'name': 'User', // You might want to get this from user profile
        'age': int.tryParse(age.value) ?? 0,
        'weight': double.tryParse(weight.value) ?? 0.0,
        'height': int.tryParse(height.value) ?? 0,
        'fitness_goal': fitnessGoal.value.toLowerCase(),
        'experience': experience.value.toLowerCase(),
        'equipment': equipment.map((e) => e.toLowerCase()).toList(),
        'limitations': limitations.value,
      };

      final response = await http.post(
        Uri.parse('${AppRoute.baseUrl}/api/fitness/generate_workout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Store the entire response for potential future use
          workoutPlan.value = {
            'title': data['workout']['plan']['title'],
            'duration': data['workout']['plan']['duration'],
            'intensity': data['workout']['plan']['intensity'],
            'overview': data['message'],
            'bmi': data['bmi'],
            'days': data['workout']['plan']['details']['days'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to generate workout plan');
        }
      } else {
        throw Exception(
            'Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
