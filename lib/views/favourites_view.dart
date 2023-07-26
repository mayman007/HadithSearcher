import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hadithsearcher/utilities/show_navigation_drawer.dart';
import 'package:hadithsearcher/views/search_view.dart';
import 'package:hadithsearcher/views/similar_hadith_view.dart';
import '../db/database.dart';
import '../utilities/show_error_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  bool _isLoading = false;

  bool _isEmpty = true;

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    getFontFamily();
    getFontWeight();
    getFontSize();
    getPadding();
    fetchData();
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

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future copyHadith(int index) async {
    var hadith = pairedValues[index];
    var hadithText = '${hadith['hadithtext']}${hadith['hadithinfo']}';
    await Clipboard.setData(ClipboardData(text: hadithText));
  }

  List<Map> pairedValues = [];

  fetchData() async {
    setState(() {
      _isLoading = true;
    });
    pairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM favourites");
    if (response!.isEmpty) {
      setState(() {
        _isLoading = false;
        _isEmpty = true;
      });
    } else {
      var reversedResponse = List.from(response.reversed);
      for (Map hadith in reversedResponse) {
        pairedValues.add(hadith);
      }
      setState(() {
        _isLoading = false;
        _isEmpty = false;
      });
    }
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
    Future<bool> _onBackPressed() async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SearchView(), // Destination
        ),
        (route) => false,
      );
      return true;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة'),
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator() // Show CircularProgressIndicator when loading
              : Column(
                  children: [
                    _isEmpty
                        ? Container(
                            margin: const EdgeInsets.all(20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 150,
                                ),
                                Icon(
                                  Icons.star_border,
                                  size: 140,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'لم يتم إضافة أحاديث للمفضلة',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : // Results ListView
                        Expanded(
                            child: ListView.builder(
                              primary: false,
                              controller: _scrollController,
                              itemCount: pairedValues.length,
                              itemBuilder: (BuildContext context, int index) {
                                var hadith = pairedValues[index];
                                String hadithText = hadith['hadithtext'];
                                String hadithInfo = hadith['hadithinfo'];
                                String hadithId = hadith['hadithid'];
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: paddingSelectedValue,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 45,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'جاري البحث عن الشرح...'),
                                                  duration:
                                                      Duration(seconds: 5),
                                                ));
                                                try {
                                                  var url = Uri.parse(
                                                      'https://dorar-hadith-api.cyclic.app/v1/site/sharh/text/$hadithText');
                                                  var response = await http
                                                      .get(url)
                                                      .timeout(const Duration(
                                                          seconds: 16));
                                                  var decodedBody = utf8.decode(
                                                      response.bodyBytes);
                                                  var jsonResponse =
                                                      json.decode(decodedBody);

                                                  return await showErrorDialog(
                                                    context,
                                                    'الشرح',
                                                    jsonResponse['data']
                                                            ['sharhMetadata']
                                                        ['sharh'],
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
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
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SimilarHadithView(
                                                            hadithId: hadithId,
                                                          )),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.content_paste_go,
                                                size: 25,
                                              ),
                                              label: const Text(
                                                'أحاديث مشابهة',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 45,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text('تم النسخ'),
                                                  duration:
                                                      Duration(seconds: 2),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
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
                                                await sqlDb.deleteData(
                                                    "DELETE FROM 'favourites' WHERE id = ${hadith['id']}");
                                                fetchData(); // Refresh the UI after fetching data
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'تم إزالة الحديث من المفضلة'),
                                                  duration:
                                                      Duration(seconds: 3),
                                                ));
                                              },
                                              icon: const Icon(
                                                Icons.star,
                                                size: 25,
                                              ),
                                              label: const Text(
                                                'أزل من المفضلة',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
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
        drawer: const MyNavigationDrawer(),
      ),
    );
  }
}
