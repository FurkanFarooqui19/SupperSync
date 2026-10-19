import 'package:flutter/material.dart';

class ClubFormController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final inviteCodeController = TextEditingController();

  bool validate() => formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    inviteCodeController.dispose();
    super.dispose();
  }
}
