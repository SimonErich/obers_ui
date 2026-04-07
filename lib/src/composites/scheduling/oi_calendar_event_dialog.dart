import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_date_picker_field.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/components/inputs/oi_time_picker_field.dart';
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
  /// [onDeleted] is called when the user confirms deletion.
  static void show(
    BuildContext context, {
    required OiCalendarEvent event,
    required ValueChanged<OiCalendarEventResult> onSaved,
    VoidCallback? onDeleted,
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
      label: 'Edit event dialog',
      dialog: StatefulBuilder(
        builder: (context, setDialogState) => OiDialog.form(
          label: 'Edit event',
          title: 'Edit Event',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiTextInput(
                controller: controller,
                label: 'Event title',
                placeholder: 'Enter event title...',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: 'Start date',
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
                      label: 'Start time',
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
                      label: 'End date',
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
                      label: 'End time',
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
                label: 'Delete',
                onTap: () => _confirmDelete(
                  context,
                  event: event,
                  onDeleted: () {
                    handle?.dismiss();
                    onDeleted();
                  },
                ),
              ),
            OiButton.ghost(
              label: 'Cancel',
              onTap: () => handle?.dismiss(),
            ),
            OiButton.primary(
              label: 'Save',
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
  /// [onCreated] is called with the event data when the user confirms.
  static void showCreate(
    BuildContext context, {
    required DateTime date,
    required ValueChanged<OiCalendarEventResult> onCreated,
  }) {
    final controller = TextEditingController();
    var startDate = date;
    var endDate = date;
    var startTime = const OiTimeOfDay(hour: 9, minute: 0);
    var endTime = const OiTimeOfDay(hour: 10, minute: 0);
    OiOverlayHandle? handle;

    handle = OiDialog.show(
      context,
      label: 'Create event dialog',
      dialog: StatefulBuilder(
        builder: (context, setDialogState) => OiDialog.form(
          label: 'Create event',
          title: 'New Event',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiTextInput(
                controller: controller,
                label: 'Event title',
                placeholder: 'Enter event title...',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OiDatePickerField(
                      label: 'Start date',
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
                      label: 'Start time',
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
                      label: 'End date',
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
                      label: 'End time',
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
            OiButton.ghost(label: 'Cancel', onTap: () => handle?.dismiss()),
            OiButton.primary(
              label: 'Create',
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
  }) {
    OiOverlayHandle? confirmHandle;

    confirmHandle = OiDialog.show(
      context,
      label: 'Confirm delete dialog',
      dialog: OiDialog.confirm(
        label: 'Confirm delete',
        title: 'Delete Event',
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
        ),
        actions: [
          OiButton.ghost(
            label: 'Cancel',
            onTap: () => confirmHandle?.dismiss(),
          ),
          OiButton.destructive(
            label: 'Delete',
            onTap: () {
              confirmHandle?.dismiss();
              onDeleted();
              OiToast.show(
                context,
                message: 'Deleted "${event.title}"',
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
