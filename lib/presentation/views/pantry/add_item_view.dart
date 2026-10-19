import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/pantry_item_model.dart';
import '../../viewmodels/forms/pantry_form_controller.dart';
import '../../viewmodels/pantry_viewmodel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class AddItemView extends StatelessWidget {
  const AddItemView({super.key, this.editItem});

  final Map<String, dynamic>? editItem;

  PantryItemModel? get _parsedItem {
    if (editItem == null) return null;
    try {
      return PantryItemModel.fromJson({
        ...editItem!,
        'owner_id': editItem!['owner_id'] ?? '',
        'created_at':
            editItem!['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at':
            editItem!['updated_at'] ?? DateTime.now().toIso8601String(),
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PantryFormController(editItem: _parsedItem),
      child: const _AddItemBody(),
    );
  }
}

class _AddItemBody extends StatelessWidget {
  const _AddItemBody();

  Future<void> _pickDate(BuildContext context) async {
    final form = context.read<PantryFormController>();
    final picked = await showDatePicker(
      context: context,
      initialDate: form.expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) form.setExpiry(picked);
  }

  Future<void> _save(BuildContext context) async {
    final form = context.read<PantryFormController>();
    if (!form.validate()) return;

    final pantry = context.read<PantryViewModel>();

    if (form.isEditing && !pantry.isOwnerId(form.ownerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit items in your own pantry.'),
        ),
      );
      return;
    }

    final quantity = double.parse(form.quantityController.text.trim());
    bool ok;

    if (form.isEditing) {
      ok = await pantry.updateItem(form.itemId!, {
        'name': form.nameController.text.trim(),
        'quantity': quantity,
        'unit': form.unit,
        'category': form.category,
        'storage_type': form.storageType.name,
        'visibility': form.visibility.value,
        'expiry_date': form.expiryDate?.toIso8601String().split('T').first,
        'notes': form.notesController.text.trim().isEmpty
            ? null
            : form.notesController.text.trim(),
      });
    } else {
      ok = await pantry.addItem(
        name: form.nameController.text,
        quantity: quantity,
        unit: form.unit,
        category: form.category,
        storageType: form.storageType,
        expiryDate: form.expiryDate,
        visibility: form.visibility,
        notes: form.notesController.text,
      );
    }

    if (ok && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<PantryFormController>();
    final pantry = context.watch<PantryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canEdit = !form.isEditing || pantry.isOwnerId(form.ownerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          !canEdit
              ? 'View item'
              : (form.isEditing ? AppStrings.editItem : AppStrings.addItem),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canEdit) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.space3),
                  margin: const EdgeInsets.only(bottom: AppDimensions.space4),
                  decoration: BoxDecoration(
                    color: AppColors.warningMuted,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Text(
                    'This item belongs to another member. You can view it but not edit it.',
                    style: TextStyle(color: AppColors.warning),
                  ),
                ),
              ],
              AppTextField(
                controller: form.nameController,
                label: AppStrings.itemName,
                hint: 'e.g. Tomatoes',
                prefixIcon: Icons.shopping_basket_outlined,
                validator: AppValidators.required,
                enabled: canEdit,
              ),
              const SizedBox(height: AppDimensions.space4),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: form.quantityController,
                      label: AppStrings.quantity,
                      hint: '1',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: AppValidators.quantity,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.unit,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space2),
                        DropdownButtonFormField<String>(
                          value: form.unit,
                          items: PantryUnit.all
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) form.setUnit(v);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? AppColors.cardDark
                                : AppColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                AppStrings.category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              DropdownButtonFormField<String>(
                value: form.category,
                hint: const Text('Select category'),
                items: PantryCategory.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${PantryCategory.emoji[c] ?? ''} $c'),
                      ),
                    )
                    .toList(),
                onChanged: form.setCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDark ? AppColors.cardDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                AppStrings.storageType,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              Wrap(
                spacing: 8,
                children: StorageType.values.map((s) {
                  final selected = form.storageType == s;
                  return ChoiceChip(
                    label: Text('${s.emoji} ${s.label}'),
                    selected: selected,
                    onSelected: canEdit ? (_) => form.setStorage(s) : null,
                    selectedColor: AppColors.primaryMuted,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                label: AppStrings.expiryDate,
                hint: form.expiryDate?.mediumDate ?? 'Select date',
                readOnly: true,
                enabled: canEdit,
                prefixIcon: Icons.calendar_today_outlined,
                onTap: canEdit ? () => _pickDate(context) : null,
                suffixWidget: canEdit && form.expiryDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => form.setExpiry(null),
                      )
                    : null,
              ),
              const SizedBox(height: AppDimensions.space4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.shareWithClub),
                subtitle: Text(
                  form.visibility == ItemVisibility.shared
                      ? AppStrings.shared
                      : AppStrings.private,
                ),
                value: form.visibility == ItemVisibility.shared,
                activeThumbColor: AppColors.primary,
                onChanged: canEdit
                    ? (v) => form.setVisibility(
                          v ? ItemVisibility.shared : ItemVisibility.private,
                        )
                    : null,
              ),
              const SizedBox(height: AppDimensions.space3),
              AppTextField(
                controller: form.notesController,
                label: 'Notes (optional)',
                hint: 'Any extra details',
                maxLines: 3,
                enabled: canEdit,
              ),
              if (pantry.error != null) ...[
                const SizedBox(height: AppDimensions.space3),
                Text(
                  pantry.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: AppDimensions.space6),
              if (canEdit)
                AppButton(
                  label: AppStrings.save,
                  isLoading: pantry.isSaving,
                  onPressed: () => _save(context),
                ),
              const SizedBox(height: AppDimensions.space8),
            ],
          ),
        ),
      ),
    );
  }
}
