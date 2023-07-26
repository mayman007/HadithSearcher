import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../db/database.dart';
import '../utilities/show_error_dialog.dart';
import 'package:flutter/services.dart';

class SimilarHadithView extends StatefulWidget {
  const SimilarHadithView({super.key, this.hadithId});
  final String? hadithId;

  @override
  State<SimilarHadithView> createState() => _SimilarHadithViewState();
}

class _SimilarHadithViewState extends State<SimilarHadithView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  bool _isLoading = false;

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  List<bool> isFavButtonPressedList = List.generate(300, (_) => false);

  void _onFavButtonPressed(int index) {
    setState(() {
      isFavButtonPressedList[index] = !isFavButtonPressedList[index];
    });
  }

  @override
  void initState() {
    getFontFamily();
    getFontWeight();
    getFontSize();
    getPadding();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });

    callFetchData();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void callFetchData() async {
    setState(() {
      _isLoading = true; // Display CircularProgressIndicator
      _showBackToTopButton = false;
    });
    await fetchData(widget.hadithId ?? 'No id passed');
    setState(() {
      _isLoading = false; // Hide CircularProgressIndicator
    });
  }

  Future copyHadith(int index) async {
    var hadith = pairedValues[index];
    var hadithText =
        '${hadith['hadith']}\n\nالراوي: ${hadith['rawi']}\nالمحدث: ${hadith['mohdith']}\nالمصدر: ${hadith['book']}\nالصفحة أو الرقم: ${hadith['numberOrPage']}\nخلاصة حكم المحدث: ${hadith['grade']}';
    await Clipboard.setData(ClipboardData(text: hadithText));
  }

  List<Map> pairedValues = [];

  Future<void> fetchData(String hadithId) async {
    const CircularProgressIndicator();
    if (hadithId == '') {
      return await showErrorDialog(
        context,
        'أكتب شئ',
        'لا يمكنك ترك خانة البحث فارغة',
      );
    }
    try {
      var url = Uri.parse(
          'https://dorar-hadith-api.cyclic.app/v1/site/hadith/similar/$hadithId');
      var response = await http.get(url).timeout(const Duration(seconds: 32));
      var decodedBody = utf8.decode(response.bodyBytes);
      var jsonResponse = json.decode(decodedBody);

      if (jsonResponse['metadata']['length'] == 0) {
        return await showErrorDialog(
          context,
          'لا توجد نتائج',
          'لا توجد أحاديث مشابهة لهذا الحديث',
        );
      } else {
        pairedValues = [];

        int current = -1;
        for (Map hadith in jsonResponse['data']) {
          current += 1;
          pairedValues.add(hadith);
          var favHadiths = await sqlDb.selectData("SELECT * FROM 'favourites'");
          for (var row in favHadiths) {
            if (row['hadithid'] == hadith['hadithId']) {
              setState(() {
                isFavButtonPressedList[current] = true;
              });
              break;
            }
          }
        }
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
    setState(() {}); // Refresh the UI after fetching data
  }

  String fontFamilySelectedValue = 'Roboto';
  FontWeight fontWeightSelectedValue = FontWeight.normal;
  double fontSizeSelectedValue = 20;
  EdgeInsets paddingSelectedValue = const EdgeInsets.all(10);

  List<Map> settingsPairedValues = [];

  getFontFamily() async {
    settingsPairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM settings");
    for (Map hadith in response!) {
      settingsPairedValues.add(hadith);
    }
    setState(() {
      fontFamilySelectedValue = settingsPairedValues[0]['fontfamily'];
    });
  }

  getFontWeight() async {
    settingsPairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM settings");
    for (Map hadith in response!) {
      settingsPairedValues.add(hadith);
    }

    if (settingsPairedValues[0]['fontweight'] == 'normal') {
      setState(() {
        fontWeightSelectedValue = FontWeight.normal;
      });
      return fontWeightSelectedValue = FontWeight.normal;
    } else if (settingsPairedValues[0]['fontweight'] == 'bold') {
      setState(() {
        fontWeightSelectedValue = FontWeight.bold;
      });
    }
  }

  getFontSize() async {
    settingsPairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM settings");
    for (Map hadith in response!) {
      settingsPairedValues.add(hadith);
    }

    int intValue = settingsPairedValues[0]['fontsize'];
    setState(() {
      fontSizeSelectedValue = intValue.toDouble();
    });
  }

  getPadding() async {
    settingsPairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM settings");
    for (Map hadith in response!) {
      settingsPairedValues.add(hadith);
    }

    int intValue = settingsPairedValues[0]['padding'];
    setState(() {
      paddingSelectedValue = EdgeInsets.all(intValue.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أحاديث مشابهة',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show CircularProgressIndicator when loading
            : Column(
                children: [
                  // Results ListView
                  Expanded(
                    child: ListView.builder(
                      primary: false,
                      controller: _scrollController,
                      itemCount: pairedValues.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map hadith = pairedValues[index];
                        String hadithText = hadith['hadith'];
                        String hadithInfo =
                            'الراوي: ${hadith['rawi']}\nالمحدث: ${hadith['mohdith']}\nالمصدر: ${hadith['book']}\nالصفحة أو الرقم: ${hadith['numberOrPage']}\nخلاصة حكم المحدث: ${hadith['grade']}';
                        String hadithId = hadith['hadithId'];
                        return Container(
                          margin: const EdgeInsets.all(10),
                          padding: paddingSelectedValue,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              SelectableText(
                                '$hadithText\n\n$hadithInfo',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  fontSize: fontSizeSelectedValue,
                                  fontWeight: fontWeightSelectedValue,
                                  fontFamily: fontFamilySelectedValue,
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text('جارِ البحث عن الشرح...'),
                                          duration: Duration(seconds: 5),
                                        ));
                                        try {
                                          var url = Uri.parse(
                                              'https://dorar-hadith-api.cyclic.app/v1/site/sharh/text/${hadith['hadith']}');
                                          var response = await http
                                              .get(url)
                                              .timeout(
                                                  const Duration(seconds: 16));
                                          var decodedBody =
                                              utf8.decode(response.bodyBytes);
                                          var jsonResponse =
                                              json.decode(decodedBody);

                                          AlertDialog(
                                            content: Text(jsonResponse['data']
                                                ['sharhMetadata']['sharh']),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('إغلاق'),
                                              )
                                            ],
                                          );
                                          return await showErrorDialog(
                                            context,
                                            'الشرح',
                                            jsonResponse['data']
                                                ['sharhMetadata']['sharh'],
                                          );
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('تم النسخ'),
                                          duration: Duration(seconds: 2),
                                        ));
                                        await copyHadith(index);
                                      },
                                      icon: const Icon(
                                        Icons.copy,
                                        size: 25,
                                      ),
                                      label: const Text(
                                        'نسخ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
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
                                        print('hadithId $hadithId');
                                        var dbHadithId = await sqlDb.selectData(
                                            "SELECT * FROM 'favourites'");
                                        for (var row in dbHadithId) {
                                          if (row['hadithid'] == hadithId) {
                                            await sqlDb.deleteData(
                                                "DELETE FROM 'favourites' WHERE id = ${row['id']}");
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'تم إزالة الحديث من المفضلة'),
                                              duration: Duration(seconds: 3),
                                            ));
                                            _onFavButtonPressed(index);
                                            return;
                                          }
                                        }
                                        await sqlDb.insertData(
                                            "INSERT INTO 'favourites' ('hadithtext', 'hadithinfo', 'hadithid') VALUES ('$hadithText', '$hadithInfo', '$hadithId')");
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'تم إضافة الحديث إلي المفضلة'),
                                          duration: Duration(seconds: 3),
                                        ));
                                        _onFavButtonPressed(index);
                                      },
                                      icon: Icon(
                                        isFavButtonPressedList[index]
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 25,
                                      ),
                                      label: Text(
                                        isFavButtonPressedList[index]
                                            ? 'أزل من المفضلة'
                                            : 'أضف إلي المفضلة',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _showBackToTopButton == false
          ? null
          : FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
    );
  }
}
