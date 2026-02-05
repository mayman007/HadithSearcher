import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a dialog with a message.
Future<void> showMessageDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              SelectableText(
                content,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: content));
                },
                child: const Text('نسخ'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

/// Shows an error dialog based on error type.
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showMessageDialog(context, title: title, content: content);
}
