import 'package:flutter/cupertino.dart';

Future<void> showDatePickerModal({
  required BuildContext context,
  required ValueNotifier<String> notifier,
  // required Function(DateTime) onDateSelected,
}) async {
  showCupertinoModalPopup(
    context: context,
    builder:
        (context) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: CupertinoColors.systemBackground.resolveFrom(context),
          ),
          height: 200,
          padding: const EdgeInsets.only(top: 5),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime newDateTime) {
                notifier.value = newDateTime.toString().substring(0, 10);
              },
            ),
          ),
        ),
  );
}
