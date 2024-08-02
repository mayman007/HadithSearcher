import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showMsgDialog(
  BuildContext context,
  String theTitle,
  String theDiscrebtion,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          title: Text(theTitle),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  SelectableText(
                    theDiscrebtion,
                    style: const TextStyle(fontSize: 20),
                  ),
                ]),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: theDiscrebtion));
                  },
                  child: const Text('نسخ'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ],
        );
      });
}
