import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hadithsearcher/widgets/show_error_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hadithsearcher/db/database.dart';
import 'package:hadithsearcher/views/similar_hadith_view.dart';
import 'package:http/http.dart' as http;

class HadithContainer extends StatefulWidget {
  final EdgeInsets paddingSelectedValue;
  final double fontSizeSelectedValue;
  final FontWeight fontWeightSelectedValue;
  final String fontFamilySelectedValue;

  final String hadithText;
  final String hadithInfo;
  final Map hadith;
  final String hadithId;

  final bool isFavButtonPressedListIndex;
  final int index;

  final bool isSimilarHadith;

  const HadithContainer({
    super.key,
    required this.paddingSelectedValue,
    required this.fontSizeSelectedValue,
    required this.fontWeightSelectedValue,
    required this.fontFamilySelectedValue,
    required this.hadithText,
    required this.hadithInfo,
    required this.hadith,
    required this.hadithId,
    required this.isFavButtonPressedListIndex,
    required this.index,
    required this.isSimilarHadith,
  });

  @override
  State<HadithContainer> createState() => _HadithContainerState();
}

class _HadithContainerState extends State<HadithContainer> {
  DatabaseHelper sqlDb = DatabaseHelper();

  String hadithApiBaseUrl = dotenv.env['HADITH_API_BASE_URL']!;

  bool isFavButtonPressedListIndex = false;

  void _onFavButtonPressed(int index) {
    setState(() {
      isFavButtonPressedListIndex = !isFavButtonPressedListIndex;
    });
  }

  @override
  void initState() {
    setState(() {
      isFavButtonPressedListIndex = widget.isFavButtonPressedListIndex;
    });
    super.initState();
  }

  Future copyHadith(int index) async {
    var hadith = widget.hadith;
    var hadithText =
        '${hadith['hadith']}\n\nالراوي: ${hadith['rawi']}\nالمحدث: ${hadith['mohdith']}\nالمصدر: ${hadith['book']}\nالصفحة أو الرقم: ${hadith['numberOrPage']}\nخلاصة حكم المحدث: ${hadith['grade']}';
    await Clipboard.setData(ClipboardData(text: hadithText));
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(10),
        padding: widget.paddingSelectedValue,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            SelectableText(
              '${widget.hadithText}\n\n${widget.hadithInfo}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondaryContainer,
                fontSize: widget.fontSizeSelectedValue,
                fontWeight: widget.fontWeightSelectedValue,
                fontFamily: widget.fontFamilySelectedValue,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        if (widget.hadith['hasSharhMetadata'] == true) {
                          var url = Uri.parse(
                              "$hadithApiBaseUrl/v1/site/sharh/${widget.hadith['sharhMetadata']['id']}");
                          var response = await http
                              .get(url)
                              .timeout(const Duration(seconds: 8));
                          var decodedBody = utf8.decode(response.bodyBytes);
                          var jsonResponse = json.decode(decodedBody);

                          return await showErrorDialog(
                            context,
                            'الشرح',
                            jsonResponse['data']['sharhMetadata']['sharh'],
                          );
                        } else {
                          return await showErrorDialog(
                            context,
                            'الشرح',
                            'لم يتم إيجاد شرح لهذا الحديث',
                          );
                        }
                      } on http.ClientException {
                        return await showErrorDialog(
                          context,
                          'خطأ بالإتصال بالإنترنت',
                          'تأكد من إتصالك بالإنترنت وأعد المحاولة',
                        );
                      } on TimeoutException {
                        return await showErrorDialog(
                          context,
                          'نفذ الوقت',
                          'تأكد من إتصالك بإنترنت مستقر وأعد المحاولة',
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.manage_search,
                      size: 25,
                    ),
                    label: const Text(
                      'الشرح',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                widget.isSimilarHadith
                    ? const SizedBox()
                    : SizedBox(
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SimilarHadithView(
                                        hadithId: widget.hadithId,
                                      )),
                            );
                          },
                          icon: const Icon(
                            Icons.content_paste_go,
                            size: 25,
                          ),
                          label: const Text(
                            'أحاديث مشابهة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Fluttertoast.showToast(
                        msg: 'تم النسخ',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                      await copyHadith(widget.index);
                    },
                    icon: const Icon(
                      Icons.copy,
                      size: 25,
                    ),
                    label: const Text(
                      'نسخ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      var dbHadithId =
                          await sqlDb.selectData("SELECT * FROM 'favourites'");
                      for (var row in dbHadithId) {
                        if (row['hadithid'] == widget.hadithId) {
                          await sqlDb.deleteData(
                              "DELETE FROM 'favourites' WHERE id = ${row['id']}");
                          Fluttertoast.showToast(
                            msg: 'تم إزالة الحديث من المفضلة',
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          _onFavButtonPressed(widget.index);
                          return;
                        }
                      }
                      await sqlDb.insertData(
                          "INSERT INTO 'favourites' ('hadithtext', 'hadithinfo', 'hadithid') VALUES ('${widget.hadithText}', '${widget.hadithInfo}', '${widget.hadithId}')");
                      Fluttertoast.showToast(
                        msg: 'تم إضافة الحديث إلي المفضلة',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                      _onFavButtonPressed(widget.index);
                    },
                    icon: Icon(
                      isFavButtonPressedListIndex
                          ? Icons.star
                          : Icons.star_border,
                      size: 25,
                    ),
                    label: Text(
                      isFavButtonPressedListIndex
                          ? 'أزل من المفضلة'
                          : 'أضف إلي المفضلة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
