import 'package:flutter/material.dart';

class EventFormController extends ChangeNotifier {
  EventFormController({String? preselectedClubId})
      : selectedClubId = preselectedClubId;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final themeController = TextEditingController();
  final maxAttendeesController = TextEditingController();

  String? selectedClubId;
  DateTime eventDate = DateTime.now().add(const Duration(days: 3));

  void setClubId(String? id) {
    selectedClubId = id;
    notifyListeners();
  }

  void setEventDate(DateTime date) {
    eventDate = date;
    notifyListeners();
  }

  bool validate() =>
      (formKey.currentState?.validate() ?? false) && selectedClubId != null;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    themeController.dispose();
    maxAttendeesController.dispose();
    super.dispose();
  }
}
