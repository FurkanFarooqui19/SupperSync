import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/club_viewmodel.dart';
import '../../viewmodels/event_viewmodel.dart';
import '../../viewmodels/forms/event_form_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key, this.preselectedClubId});

  final String? preselectedClubId;

  @override
  Widget build(BuildContext context) {
    final clubs = context.read<ClubViewModel>();
    if (!clubs.hasLoaded && !clubs.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        clubs.loadClubs();
      });
    }

    return ChangeNotifierProvider(
      create: (_) => EventFormController(preselectedClubId: preselectedClubId),
      child: const _CreateEventBody(),
    );
  }
}

class _CreateEventBody extends StatelessWidget {
  const _CreateEventBody();

  Future<void> _pickDateTime(BuildContext context) async {
    final form = context.read<EventFormController>();
    final date = await showDatePicker(
      context: context,
      initialDate: form.eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(form.eventDate),
    );
    if (time == null) return;

    form.setEventDate(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  Future<void> _create(BuildContext context) async {
    final form = context.read<EventFormController>();
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final event = await context.read<EventViewModel>().createEvent(
          clubId: form.selectedClubId!,
          title: form.titleController.text,
          eventDate: form.eventDate,
          description: form.descriptionController.text.trim().isEmpty
              ? null
              : form.descriptionController.text,
          location: form.locationController.text.trim().isEmpty
              ? null
              : form.locationController.text,
          theme: form.themeController.text.trim().isEmpty
              ? null
              : form.themeController.text,
          maxAttendees: int.tryParse(form.maxAttendeesController.text),
        );

    if (event != null && context.mounted) {
      context.go('/events/${event.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<EventFormController>();
    final events = context.watch<EventViewModel>();
    final clubs = context.watch<ClubViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createEvent)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Club',
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
                value: form.selectedClubId,
                hint: const Text('Select a club'),
                items: clubs.clubs
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: form.setClubId,
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
              AppTextField(
                controller: form.titleController,
                label: AppStrings.eventTitle,
                hint: 'Sunday Supper',
                prefixIcon: Icons.restaurant_menu_rounded,
                validator: AppValidators.required,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                label: AppStrings.eventDate,
                hint: form.eventDate.fullDateTime,
                readOnly: true,
                prefixIcon: Icons.calendar_today_outlined,
                onTap: () => _pickDateTime(context),
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.locationController,
                label: AppStrings.eventLocation,
                hint: 'Whose place?',
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.themeController,
                label: AppStrings.eventTheme,
                hint: 'Italian night, BBQ, brunch...',
                prefixIcon: Icons.local_offer_outlined,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.maxAttendeesController,
                label: AppStrings.maxAttendees,
                hint: 'Optional',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.people_outline_rounded,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.descriptionController,
                label: 'Description',
                hint: 'Any notes for the group',
                maxLines: 3,
              ),
              if (events.error != null) ...[
                const SizedBox(height: AppDimensions.space3),
                Text(
                  events.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: AppDimensions.space6),
              AppButton(
                label: AppStrings.createEvent,
                isLoading: events.isSaving,
                onPressed: () => _create(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
