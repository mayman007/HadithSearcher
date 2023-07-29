import 'package:flutter/material.dart';
import 'package:hadithsearcher/db/database.dart';
import 'package:hadithsearcher/views/similar_hadith_view.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../utilities/show_error_dialog.dart';
import '../utilities/show_navigation_drawer.dart';
import 'package:flutter/services.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  bool _isLoading = false;

  bool _isEmpty = true;

  final textFieldController = TextEditingController();

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  List<bool> isFavButtonPressedList = List.generate(30, (_) => false);

  void _onFavButtonPressed(int index) {
    setState(() {
      isFavButtonPressedList[index] = !isFavButtonPressedList[index];
    });
  }

  @override
  void initState() {
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
    textFieldController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future copyHadith(int index) async {
    var hadith = pairedValues[index];
    var hadithText =
        '${hadith['hadith']}\n\nالراوي: ${hadith['rawi']}\nالمحدث: ${hadith['mohdith']}\nالمصدر: ${hadith['book']}\nالصفحة أو الرقم: ${hadith['numberOrPage']}\nخلاصة حكم المحدث: ${hadith['grade']}';
    await Clipboard.setData(ClipboardData(text: hadithText));
  }

  List<Map> pairedValues = [];

  String searchKeyword = '';

  int searchPagaNumber = 1;

  Future<void> fetchData() async {
    if (searchKeyword == '') {
      return await showErrorDialog(
        context,
        'أكتب شئ',
        'لا يمكنك ترك خانة البحث فارغة',
      );
    }
    getFontFamily();
    getFontWeight();
    getFontSize();
    getPadding();
    try {
      String searchWay = '';
      String searchRange = '';
      String searchGrade = '';
      String searchMohdith = '';
      String searchBook = '';

      if (searchWaySelectedValue == 'أي كلمة') {
        searchWay = 'a';
      } else if (searchWaySelectedValue == 'جميع الكلمات') {
        searchWay = 'w';
      } else if (searchWaySelectedValue == 'بحث مطابق') {
        searchWay = 'p';
      }

      if (searchRangeSelectedValue == 'جميع الأحاديث') {
        searchRange = '*';
      } else if (searchRangeSelectedValue == 'الأحاديث المرفوعة') {
        searchRange = '0';
      } else if (searchRangeSelectedValue == 'الأحاديث القدسية') {
        searchRange = '1';
      } else if (searchRangeSelectedValue == 'آثار الصحابة') {
        searchRange = '2';
      } else if (searchRangeSelectedValue == 'شروح الأحاديث') {
        searchRange = '3';
      }

      if (searchGradeSelectedValue == 'جميع الدرجات') {
        searchGrade = '0';
      } else if (searchGradeSelectedValue == 'أحاديث صحيحة') {
        searchGrade = '1';
      } else if (searchGradeSelectedValue == 'أحاديث أسانيدها صحيحة') {
        searchGrade = '2';
      } else if (searchGradeSelectedValue == 'أحاديث صعيفة') {
        searchGrade = '3';
      } else if (searchGradeSelectedValue == 'أحاديث أسانيدها ضعيفة') {
        searchGrade = '4';
      }

      if (searchMohdithSelectedValue == 'جميع المحدثين') {
        searchMohdith = '0';
      } else if (searchMohdithSelectedValue == 'الإمام المالك') {
        searchMohdith = '179';
      } else if (searchMohdithSelectedValue == 'الإمام الشافعي') {
        searchMohdith = '204';
      } else if (searchMohdithSelectedValue == 'البخاري') {
        searchMohdith = '256';
      } else if (searchMohdithSelectedValue == 'مسلم') {
        searchMohdith = '261';
      }

      if (searchBookSelectedValue == 'جميع الكتب') {
        searchBook = '0';
      } else if (searchBookSelectedValue == 'الأربعون النووية') {
        searchBook = '13457';
      } else if (searchBookSelectedValue == 'صحيح البخاري') {
        searchBook = '6216';
      } else if (searchBookSelectedValue == 'صحيح مسلم') {
        searchBook = '3088';
      } else if (searchBookSelectedValue == 'الصحيح المسند') {
        searchBook = '96';
      }
      var url = Uri.parse(
          'https://dorar-hadith-api.cyclic.app/v1/site/hadith/search?value=$searchKeyword&page=$searchPagaNumber&st=$searchWay&t=$searchRange&d[]=$searchGrade&m[]=$searchMohdith&s[]=$searchBook$searchExcludedWords');
      print(url);
      var response = await http.get(url).timeout(const Duration(seconds: 24));
      var decodedBody = utf8.decode(response.bodyBytes);
      var jsonResponse = json.decode(decodedBody);

      if (jsonResponse['metadata']['length'] == 0) {
        if (searchPagaNumber > 1) {
          setState(() {
            searchPagaNumber -= 1;
          });
        }
        return await showErrorDialog(
          context,
          'لا توجد نتائج',
          'إستخدم كلمات أو إعدادات أخرى',
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
    setState(() {
      _isEmpty = false;
    }); // Refresh the UI after fetching data
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

  var isFavButtonPressed = false;

  String searchWaySelectedValue = 'أي كلمة';
  var searchWayList = [
    'أي كلمة',
    'جميع الكلمات',
    'بحث مطابق',
  ];

  String searchRangeSelectedValue = 'جميع الأحاديث';
  var searchRangeList = [
    'جميع الأحاديث',
    'الأحاديث المرفوعة',
    'الأحاديث القدسية',
    'آثار الصحابة',
    'شروح الأحاديث',
  ];

  String searchGradeSelectedValue = 'جميع الدرجات';
  var searchGradeList = [
    'جميع الدرجات',
    'أحاديث صحيحة',
    'أحاديث أسانيدها صحيحة',
    'أحاديث ضعيفة',
    'أحاديث أسانيدها ضعيفة',
  ];

  String searchMohdithSelectedValue = 'جميع المحدثين';
  var searchMohdithList = [
    'جميع المحدثين',
    'الإمام المالك',
    'الإمام الشافعي',
    'البخاري',
    'مسلم',
  ];

  String searchBookSelectedValue = 'جميع الكتب';
  var searchBookList = [
    'جميع الكتب',
    'الأربعون النووية',
    'صحيح البخاري',
    'صحيح مسلم',
    'الصحيح المسند',
  ];

  String searchExcludedWords = '';

  bool isAdvancedSearchEnabled = false;

  @override
  Widget build(BuildContext context) {
    // To adjust search's textfield based on screen's width
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldWidth = screenWidth * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Advanced search button
          IconButton(
            onPressed: () {
              setState(() {
                isAdvancedSearchEnabled = !isAdvancedSearchEnabled;
              });
            },
            icon: const Icon(
              Icons.settings,
              size: 30,
            ),
            tooltip: 'إعدادات البحث',
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show CircularProgressIndicator when loading
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: textFieldWidth,
                        height: 60,
                        // Search TextField
                        child: TextField(
                          controller: textFieldController,
                          decoration: const InputDecoration(
                            hintText: 'تحقق من حديث...',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          onSubmitted: (value) async {
                            setState(() {
                              searchPagaNumber = 1;
                              isAdvancedSearchEnabled = false;
                              searchKeyword = textFieldController.text;
                              _isLoading =
                                  true; // Display CircularProgressIndicator
                              _showBackToTopButton = false;
                            });
                            await fetchData();
                            setState(() {
                              _isLoading =
                                  false; // Hide CircularProgressIndicator
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        // Search button
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.search,
                            size: 30.0,
                          ),
                          label: const Text('بحث'),
                          onPressed: () async {
                            setState(() {
                              searchPagaNumber = 1;
                              isAdvancedSearchEnabled = false;
                              searchKeyword = textFieldController.text;
                              _isLoading =
                                  true; // Display CircularProgressIndicator
                              _showBackToTopButton = false;
                            });
                            await fetchData();
                            setState(() {
                              _isLoading =
                                  false; // Hide CircularProgressIndicator
                            });
                          },
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
                  isAdvancedSearchEnabled
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'إعدادات البحث',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // Combobox
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'طريقة البحث',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              // dropdown below..
                                              child: DropdownButton<String>(
                                                value: searchWaySelectedValue,
                                                onChanged:
                                                    (String? newValue) async {
                                                  setState(
                                                    () {
                                                      searchWaySelectedValue =
                                                          newValue!;
                                                    },
                                                  );
                                                },
                                                items: searchWayList
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                // add extra sugar..
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 35,
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Combobox
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'نطاق البحث',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              // dropdown below..
                                              child: DropdownButton<String>(
                                                value: searchRangeSelectedValue,
                                                onChanged:
                                                    (String? newValue) async {
                                                  setState(
                                                    () {
                                                      searchRangeSelectedValue =
                                                          newValue!;
                                                    },
                                                  );
                                                },
                                                items: searchRangeList
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                // add extra sugar..
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 35,
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Combobox
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'درجة الحديث',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              // dropdown below..
                                              child: DropdownButton<String>(
                                                value: searchGradeSelectedValue,
                                                onChanged:
                                                    (String? newValue) async {
                                                  setState(
                                                    () {
                                                      searchGradeSelectedValue =
                                                          newValue!;
                                                    },
                                                  );
                                                },
                                                items: searchGradeList
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                // add extra sugar..
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 35,
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Combobox
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'المحدث',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              // dropdown below..
                                              child: DropdownButton<String>(
                                                value:
                                                    searchMohdithSelectedValue,
                                                onChanged:
                                                    (String? newValue) async {
                                                  setState(
                                                    () {
                                                      searchMohdithSelectedValue =
                                                          newValue!;
                                                    },
                                                  );
                                                },
                                                items: searchMohdithList
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                // add extra sugar..
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 35,
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Combobox
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'الكتاب',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              // dropdown below..
                                              child: DropdownButton<String>(
                                                value: searchBookSelectedValue,
                                                onChanged:
                                                    (String? newValue) async {
                                                  setState(
                                                    () {
                                                      searchBookSelectedValue =
                                                          newValue!;
                                                    },
                                                  );
                                                },
                                                items: searchBookList
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                // add extra sugar..
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 35,
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 250,
                                      height: 60,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText:
                                              'كلمة أو جملة تريد استبعادها من البحث',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            searchExcludedWords =
                                                '&xclude=$value';
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : _isEmpty
                          ? Container(
                              margin: const EdgeInsets.all(20),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Icon(
                                    Icons.search,
                                    size: 140,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'تأكد من صحة الأحاديث',
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
                                                  try {
                                                    if (hadith[
                                                            'hasSharhMetadata'] ==
                                                        true) {
                                                      var url = Uri.parse(
                                                          "https://dorar-hadith-api.cyclic.app/v1/site/sharh/${hadith['sharhMetadata']['id']}");
                                                      var response = await http
                                                          .get(url)
                                                          .timeout(
                                                              const Duration(
                                                                  seconds: 8));
                                                      var decodedBody =
                                                          utf8.decode(response
                                                              .bodyBytes);
                                                      var jsonResponse = json
                                                          .decode(decodedBody);

                                                      return await showErrorDialog(
                                                        context,
                                                        'الشرح',
                                                        jsonResponse['data'][
                                                                'sharhMetadata']
                                                            ['sharh'],
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
                                                              hadithId:
                                                                  hadithId,
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
                                                  var dbHadithId =
                                                      await sqlDb.selectData(
                                                          "SELECT * FROM 'favourites'");
                                                  for (var row in dbHadithId) {
                                                    if (row['hadithid'] ==
                                                        hadithId) {
                                                      await sqlDb.deleteData(
                                                          "DELETE FROM 'favourites' WHERE id = ${row['id']}");
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            'تم إزالة الحديث من المفضلة'),
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ));
                                                      _onFavButtonPressed(
                                                          index);
                                                      return;
                                                    }
                                                  }
                                                  await sqlDb.insertData(
                                                      "INSERT INTO 'favourites' ('hadithtext', 'hadithinfo', 'hadithid') VALUES ('$hadithText', '$hadithInfo', '$hadithId')");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'تم إضافة الحديث إلي المفضلة'),
                                                    duration:
                                                        Duration(seconds: 3),
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
                  _isEmpty
                      ? const Text('')
                      : isAdvancedSearchEnabled
                          ? const Text('')
                          : Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            searchPagaNumber =
                                                searchPagaNumber + 1;
                                            _isLoading =
                                                true; // Display CircularProgressIndicator
                                            _showBackToTopButton = false;
                                          });
                                          await fetchData();
                                          setState(() {
                                            _isLoading =
                                                false; // Hide CircularProgressIndicator
                                          });
                                        },
                                        icon: const Icon(Icons.arrow_back),
                                        label: const Text('الصفحة التالية'),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$searchPagaNumber',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 45,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (searchPagaNumber > 1) {
                                            setState(() {
                                              searchPagaNumber =
                                                  searchPagaNumber - 1;
                                              _isLoading =
                                                  true; // Display CircularProgressIndicator
                                              _showBackToTopButton = false;
                                            });
                                            await fetchData();
                                            setState(() {
                                              _isLoading =
                                                  false; // Hide CircularProgressIndicator
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                        label: const Text('الصفحة السابقة'),
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
                              ],
                            ),
                ],
              ),
      ),
      floatingActionButton: _showBackToTopButton == false
          ? null
          : Container(
              margin: const EdgeInsets.symmetric(vertical: 60),
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
      drawer: const MyNavigationDrawer(),
    );
  }
}
