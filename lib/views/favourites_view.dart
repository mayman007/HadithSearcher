import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hadithsearcher/widgets/show_navigation_drawer.dart';
import '../constants/routes.dart';
import '../db/database.dart';
import '../widgets/hadith_container.dart';
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
                              controller: _scrollController,
                              itemCount: pairedValues.length,
                              itemBuilder: (BuildContext context, int index) {
                                var hadith = pairedValues[index];
                                String hadithText = hadith['hadithtext'];
                                String hadithInfo = hadith['hadithinfo'];
                                String hadithId = hadith['hadithid'];
                                return HadithContainer(
                                  paddingSelectedValue: paddingSelectedValue,
                                  fontSizeSelectedValue: fontSizeSelectedValue,
                                  fontWeightSelectedValue:
                                      fontWeightSelectedValue,
                                  fontFamilySelectedValue:
                                      fontFamilySelectedValue,
                                  hadith: hadith,
                                  hadithInfo: hadithInfo,
                                  hadithId: hadithId,
                                  hadithText: hadithText,
                                  isFavButtonPressedListIndex: true,
                                  index: index,
                                  isSimilarHadith: false,
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
