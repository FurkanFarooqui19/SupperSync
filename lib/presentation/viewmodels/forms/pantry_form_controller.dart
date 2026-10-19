import 'package:flutter/material.dart';

import '../../../data/models/pantry_item_model.dart';

/// Local form state for add/edit pantry item — no setState().
class PantryFormController extends ChangeNotifier {
  PantryFormController({PantryItemModel? editItem}) {
    if (editItem != null) {
      nameController.text = editItem.name;
      quantityController.text = editItem.quantity.toString();
      unit = editItem.unit;
      category = editItem.category;
      storageType = editItem.storageType;
      visibility = editItem.visibility;
      expiryDate = editItem.expiryDate;
      notesController.text = editItem.notes ?? '';
      itemId = editItem.id;
      ownerId = editItem.ownerId;
    }
  }

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  String? itemId;
  String? ownerId;
  String unit = 'pieces';
  String? category;
  StorageType storageType = StorageType.pantry;
  ItemVisibility visibility = ItemVisibility.private;
  DateTime? expiryDate;

  bool get isEditing => itemId != null;

  void setUnit(String value) {
    unit = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    category = value;
    notifyListeners();
  }

  void setStorage(StorageType value) {
    storageType = value;
    notifyListeners();
  }

  void setVisibility(ItemVisibility value) {
    visibility = value;
    notifyListeners();
  }

  void setExpiry(DateTime? value) {
    expiryDate = value;
    notifyListeners();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
