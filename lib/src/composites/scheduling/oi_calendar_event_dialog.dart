import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_date_picker_field.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/components/inputs/oi_time_picker_field.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/components/navigation/oi_time_picker.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';

/// Result returned via callbacks from [OiCalendarEventDialog].
@immutable
class OiCalendarEventResult {
  /// Creates an [OiCalendarEventResult].
  const OiCalendarEventResult({
    required this.title,
    required this.start,
    required this.end,
  });

  /// The event title entered by the user.
  final String title;

  /// The selected start date/time.
  final DateTime start;

  /// The selected end date/time.
  final DateTime end;
}

/// The texts of an [OiCalendarEventDialog], in English by default; pass
/// translations to localize the dialogs.
///
/// {@category Composites}
class OiCalendarEventDialogLabels {
  /// Creates an [OiCalendarEventDialogLabels].
  const OiCalendarEventDialogLabels({
    this.editTitle = 'Edit Event',
    this.createTitle = 'New Event',
    this.deleteTitle = 'Delete Event',
    this.eventTitle = 'Event title',
    this.eventTitlePlaceholder = 'Enter event title...',
    this.startDate = 'Start date',
    this.startTime = 'Start time',
    this.endDate = 'End date',
    this.endTime = 'End time',
    this.save = 'Save',
    this.create = 'Create',
    this.delete = 'Delete',
    this.cancel = 'Cancel',
    this.confirmDelete = englishConfirmDelete,
    this.deleted = englishDeleted,
    this.editDialog = 'Edit event dialog',
    this.editForm = 'Edit event',
    this.createDialog = 'Create event dialog',
    this.createForm = 'Create event',
    this.confirmDeleteDialog = 'Confirm delete dialog',
    this.confirmDeleteForm = 'Confirm delete',
    this.datePicker = const OiDatePickerLabels(),
    this.timePicker = const OiTimePickerLabels(),
  });

  /// 'Are you sure you want to delete "Standup"?': the default
  /// [confirmDelete].
  static String englishConfirmDelete(String title) =>
      'Are you sure you want to delete "$title"?';

  /// 'Deleted "Standup"': the default [deleted].
  static String englishDeleted(String title) => 'Deleted "$title"';

  /// Title of the edit dialog.
  final String editTitle;

  /// Title of the create dialog.
  final String createTitle;

  /// Title of the delete confirmation.
  final String deleteTitle;

  /// Label of the title input.
  final String eventTitle;

  /// Placeholder of the title input.
  final String eventTitlePlaceholder;

  /// Label of the start date field.
  final String startDate;

  /// Label of the start time field.
  final String startTime;

  /// Label of the end date field.
  final String endDate;

  /// Label of the end time field.
  final String endTime;

  /// Label of the edit dialog's save button.
  final String save;

  /// Label of the create dialog's create button.
  final String create;

  /// Label of the delete buttons.
  final String delete;

  /// Label of the cancel buttons.
  final String cancel;

  /// Question of the delete confirmation, about the titled event.
  final String Function(String title) confirmDelete;

  /// Toast shown after the titled event is deleted.
  final String Function(String title) deleted;

  /// Screen-reader label of the edit dialog.
  final String editDialog;

  /// Screen-reader label of the edit form.
  final String editForm;

  /// Screen-reader label of the create dialog.
  final String createDialog;

  /// Screen-reader label of the create form.
  final String createForm;

  /// Screen-reader label of the delete confirmation dialog.
  final String confirmDeleteDialog;

  /// Screen-reader label of the delete confirmation.
  final String confirmDeleteForm;

  /// The texts of the date pickers that open from the date fields.
  final OiDatePickerLabels datePicker;

  /// The texts of the time pickers that open from the time fields.
  final OiTimePickerLabels timePicker;
}

/// A reusable dialog for creating and editing [OiCalendarEvent]s.
///
/// Provides date/time pickers for start and end, a title input, and
/// optional delete with confirmation.
///
/// {@category Composites}
class OiCalendarEventDialog {
  OiCalendarEventDialog._();

  /// Shows a dialog to edit an existing [event].
  ///
  /// [onSaved] is called with the updated event data when the user saves.
  /// [onDeleted] is called when the user confirms deletion. Pass [labels] to
  /// localize the dialog.
  static void show(
    BuildContext context, {
    required OiCalendarEvent event,
    required ValueChanged<OiCalendarEventResult> onSaved,
    VoidCallback? onDeleted,
    OiCalendarEventDialogLabels labels = const OiCalendarEventDialogLabels(),
  }) {
    final controller = TextEditingController(text: event.title);
    var startDate = event.start;
    var endDate = event.end;
    var startTime = OiTimeOfDay(
      hour: event.start.hour,
      minute: event.start.minute,
    );
    var endTime = OiTimeOfDay(
      hour: event.end.hour,
      minute: event.end.minute,
    );
    OiOverlayHandle? handle;

    handle = OiDialog.show(
      context,
      label: labels.editDialog,
      dialog: StatefulBuilder(
        builder: (context, setDialogState) => OiDialog.form(
          label: labels.editForm,
          title: labels.editTitle,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiTextInput(
                controller: controller,
                label: labels.eventTitle,
                placeholder: labels.eventTitlePlaceholder,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: labels.startDate,
                      pickerLabels: labels.datePicker,
                      value: startDate,
                      onChanged: (date) {
                        if (date != null) {
                          setDialogState(() => startDate = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OiTimePickerField(
                      label: labels.startTime,
                      pickerLabels: labels.timePicker,
                      value: startTime,
                      onChanged: (time) {
                        if (time != null) {
                          setDialogState(() => startTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: labels.endDate,
                      pickerLabels: labels.datePicker,
                      value: endDate,
                      onChanged: (date) {
                        if (date != null) {
                          setDialogState(() => endDate = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OiTimePickerField(
                      label: labels.endTime,
                      pickerLabels: labels.timePicker,
                      value: endTime,
                      onChanged: (time) {
                        if (time != null) {
                          setDialogState(() => endTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (onDeleted != null)
              OiButton.destructive(
                label: labels.delete,
                onTap: () => _confirmDelete(
                  context,
                  event: event,
                  labels: labels,
                  onDeleted: () {
                    handle?.dismiss();
                    onDeleted();
                  },
                ),
              ),
            OiButton.ghost(
              label: labels.cancel,
              onTap: () => handle?.dismiss(),
            ),
            OiButton.primary(
              label: labels.save,
              onTap: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  onSaved(
                    OiCalendarEventResult(
                      title: title,
                      start: DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      end: DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                      ),
                    ),
                  );
                }
                handle?.dismiss();
              },
            ),
          ],
          onClose: () => handle?.dismiss(),
        ),
      ),
    );
  }

  /// Shows a dialog to create a new event on [date].
  ///
  /// [onCreated] is called with the event data when the user confirms. Pass
  /// [labels] to localize the dialog.
  static void showCreate(
    BuildContext context, {
    required DateTime date,
    required ValueChanged<OiCalendarEventResult> onCreated,
    OiCalendarEventDialogLabels labels = const OiCalendarEventDialogLabels(),
  }) {
    final controller = TextEditingController();
    var startDate = date;
    var endDate = date;
    var startTime = const OiTimeOfDay(hour: 9, minute: 0);
    var endTime = const OiTimeOfDay(hour: 10, minute: 0);
    OiOverlayHandle? handle;

    handle = OiDialog.show(
      context,
      label: labels.createDialog,
      dialog: StatefulBuilder(
        builder: (context, setDialogState) => OiDialog.form(
          label: labels.createForm,
          title: labels.createTitle,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiTextInput(
                controller: controller,
                label: labels.eventTitle,
                placeholder: labels.eventTitlePlaceholder,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: labels.startDate,
                      pickerLabels: labels.datePicker,
                      value: startDate,
                      onChanged: (d) {
                        if (d != null) {
                          setDialogState(() => startDate = d);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OiTimePickerField(
                      label: labels.startTime,
                      pickerLabels: labels.timePicker,
                      value: startTime,
                      onChanged: (time) {
                        if (time != null) {
                          setDialogState(() => startTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: labels.endDate,
                      pickerLabels: labels.datePicker,
                      value: endDate,
                      onChanged: (d) {
                        if (d != null) {
                          setDialogState(() => endDate = d);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OiTimePickerField(
                      label: labels.endTime,
                      pickerLabels: labels.timePicker,
                      value: endTime,
                      onChanged: (time) {
                        if (time != null) {
                          setDialogState(() => endTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            OiButton.ghost(
              label: labels.cancel,
              onTap: () => handle?.dismiss(),
            ),
            OiButton.primary(
              label: labels.create,
              onTap: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  onCreated(
                    OiCalendarEventResult(
                      title: title,
                      start: DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      end: DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                      ),
                    ),
                  );
                }
                handle?.dismiss();
              },
            ),
          ],
          onClose: () => handle?.dismiss(),
        ),
      ),
    );
  }

  static void _confirmDelete(
    BuildContext context, {
    required OiCalendarEvent event,
    required VoidCallback onDeleted,
    required OiCalendarEventDialogLabels labels,
  }) {
    OiOverlayHandle? confirmHandle;

    confirmHandle = OiDialog.show(
      context,
      label: labels.confirmDeleteDialog,
      dialog: OiDialog.confirm(
        label: labels.confirmDeleteForm,
        title: labels.deleteTitle,
        content: Text(labels.confirmDelete(event.title)),
        actions: [
          OiButton.ghost(
            label: labels.cancel,
            onTap: () => confirmHandle?.dismiss(),
          ),
          OiButton.destructive(
            label: labels.delete,
            onTap: () {
              confirmHandle?.dismiss();
              onDeleted();
              OiToast.show(
                context,
                message: labels.deleted(event.title),
                level: OiToastLevel.warning,
              );
            },
          ),
        ],
        onClose: () => confirmHandle?.dismiss(),
      ),
    );
  }
}
