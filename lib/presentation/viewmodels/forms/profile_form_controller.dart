import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class ProfileFormController extends ChangeNotifier {
  ProfileFormController(UserModel? user) {
    if (user != null) {
      displayNameController.text = user.displayName;
      bioController.text = user.bio ?? '';
      dietaryTags = List<String>.from(user.dietaryTags);
    }
  }

  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  List<String> dietaryTags = [];

  static const availableTags = [
    'Vegan',
    'Vegetarian',
    'Gluten Free',
    'Dairy Free',
    'Nut Allergy',
    'Halal',
    'Kosher',
    'Pescatarian',
  ];

  void toggleTag(String tag) {
    if (dietaryTags.contains(tag)) {
      dietaryTags = dietaryTags.where((t) => t != tag).toList();
    } else {
      dietaryTags = [...dietaryTags, tag];
    }
    notifyListeners();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    displayNameController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
