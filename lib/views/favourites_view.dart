import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hadithsearcher/views/similar_hadith_view.dart';
import 'package:hadithsearcher/widgets/show_msg_dialog.dart';
import 'package:hadithsearcher/widgets/show_navigation_drawer.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/routes.dart';
import '../db/database.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  String hadithApiBaseUrl = dotenv.env['HADITH_API_BASE_URL']!;

  bool _isLoading = false;

  bool _isEmpty = true;

  bool _showBackToTopButton = false;
  late ScrollController scrollController;

  double previousOffset = 0;
  double upwardScrollDistance = 0;

  void scrollListener() async {
    setState(() {
      if (scrollController.offset >= 800) {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _showBackToTopButton = false; // Hide the back-to-top button
          upwardScrollDistance = 0;
        } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          double scrollDelta = previousOffset - scrollController.offset;
          upwardScrollDistance += scrollDelta;

          if (upwardScrollDistance >= 100) {
            _showBackToTopButton = true; // Show the back-to-top button
          }
        }
      } else {
        _showBackToTopButton = false; // Hide the back-to-top button
        upwardScrollDistance = 0;
      }

      previousOffset = scrollController.offset;
    });
  }

  @override
  void initState() {
    getFontFamily();
    getFontWeight();
    getFontSize();
    getPadding();
    fetchData();
    scrollController = ScrollController()..addListener(scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  Future shareHadith(int index, Map hadith) async {
    String hadithText = '${hadith['hadithtext']}\n\n${hadith['hadithinfo']}';

    final result = await Share.shareWithResult(hadithText);

    if (result.status == ShareResultStatus.success) {
      Fluttertoast.showToast(
        msg: 'تم المشاركة',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
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
    Future<bool> onBackPressed() async {
      Navigator.of(context).pushNamedAndRemoveUntil(
        searchRoute,
        (route) => false,
      );
      return true;
    }

    return WillPopScope(
      onWillPop: onBackPressed,
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
                              controller: scrollController,
                              itemCount: pairedValues.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map hadith = pairedValues[index];
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
                                        '${hadithText}\n\n${hadithInfo}',
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
                                                try {
                                                  if (hadith[
                                                          'hasSharhMetadata'] ==
                                                      true) {
                                                    var url = Uri.parse(
                                                        "$hadithApiBaseUrl/v1/site/sharh/${hadith['sharhMetadata']['id']}");
                                                    var response = await http
                                                        .get(url)
                                                        .timeout(const Duration(
                                                            seconds: 8));
                                                    var decodedBody =
                                                        utf8.decode(
                                                            response.bodyBytes);
                                                    var jsonResponse = json
                                                        .decode(decodedBody);

                                                    return await showMsgDialog(
                                                      context,
                                                      'الشرح',
                                                      jsonResponse['data']
                                                              ['sharhMetadata']
                                                          ['sharh'],
                                                    );
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg: 'فشل البحث عن شرح',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                    );
                                                  }
                                                } on http.ClientException {
                                                  return await showMsgDialog(
                                                    context,
                                                    'خطأ بالإتصال بالإنترنت',
                                                    'تأكد من إتصالك بالإنترنت وأعد المحاولة',
                                                  );
                                                } on TimeoutException {
                                                  return await showMsgDialog(
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
                                                log(hadith.toString());
                                                await shareHadith(
                                                    index, hadith);
                                              },
                                              icon: const Icon(
                                                Icons.share_rounded,
                                                size: 25,
                                              ),
                                              label: const Text(
                                                'مشاركة',
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
                                                var dbHadithId =
                                                    await sqlDb.selectData(
                                                        "SELECT * FROM 'favourites'");
                                                for (var row in dbHadithId) {
                                                  if (row['hadithid'] ==
                                                      hadithId) {
                                                    await sqlDb.deleteData(
                                                        "DELETE FROM 'favourites' WHERE id = ${row['id']}");
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'تم إزالة الحديث من المفضلة',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                    );
                                                    setState(() {
                                                      pairedValues
                                                          .removeAt(index);
                                                    });
                                                  }
                                                }
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
                            ).animate().fade(duration: 200.ms),
                          ),
                  ],
                ),
        ),
        floatingActionButton: _showBackToTopButton == false
            ? null
            : FloatingActionButton(
                onPressed: () {
                  scrollController.animateTo(
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
