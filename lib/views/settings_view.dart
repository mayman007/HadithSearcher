import 'package:flutter/material.dart';
import 'package:hadithsearcher/utilities/show_error_dialog.dart';

import '../db/database.dart';
import '../utilities/show_navigation_drawer.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  List<Map> pairedValues = [];

  final themeItems = ['إتباع النظام', 'الوضع الليلي', 'الوضع النهاري'];
  String themeSelectedValue = 'إتباع النظام';

  final fontFamilyItems = [
    'Roboto',
    'Amiri',
    'Lateef',
    'Gulzar',
    'Aref Ruqaa',
    'Reem Kufi'
  ];
  String fontFamilySelectedValue = 'Roboto';

  final fontWeightItems = ['عادي', 'عريض'];
  String fontWeightSelectedValue = 'عادي';

  final fontSizeItems = [10, 20, 30, 40, 50];
  int fontSizeSelectedValue = 20;

  final paddingItems = [5, 10, 15, 20, 25, 30];
  int paddingSelectedValue = 10;

  fetchData() async {
    pairedValues = [];
    List<Map<String, Object?>>? response =
        await sqlDb.selectData("SELECT * FROM settings");
    for (Map hadith in response!) {
      pairedValues.add(hadith);
    }

    if (pairedValues[0]['theme'] == 'system') {
      themeSelectedValue = 'إتباع النظام';
    } else if (pairedValues[0]['theme'] == 'dark') {
      themeSelectedValue = 'الوضع الليلي';
    } else if (pairedValues[0]['theme'] == 'light') {
      themeSelectedValue = 'الوضع النهاري';
    }

    fontFamilySelectedValue = pairedValues[0]['fontfamily'];

    if (pairedValues[0]['fontweight'] == 'normal') {
      fontWeightSelectedValue = 'عادي';
    } else if (pairedValues[0]['fontweight'] == 'bold') {
      fontWeightSelectedValue = 'عريض';
    }

    fontSizeSelectedValue = pairedValues[0]['fontsize'];

    paddingSelectedValue = pairedValues[0]['padding'];
    setState(() {}); // Refresh the UI after fetching data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'المظهر العام',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // dropdown below..
                        child: DropdownButton<String>(
                          value: themeSelectedValue,
                          onChanged: (String? newValue) async {
                            String selectedTheme = '';
                            if (newValue == 'إتباع النظام') {
                              selectedTheme = 'system';
                            } else if (newValue == 'الوضع الليلي') {
                              selectedTheme = 'dark';
                            } else if (newValue == 'الوضع النهاري') {
                              selectedTheme = 'light';
                            }

                            await sqlDb.updateData(
                                "UPDATE 'settings' SET 'theme' = '$selectedTheme' WHERE id = 1");
                            fetchData();
                            await showErrorDialog(
                              context,
                              'أعد فتح التطبيق',
                              'أعد فتح التطبيق حتى حتى يتم تغيير المظهر العام',
                            );
                          },
                          items: themeItems
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
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
            height: 20,
          ),
          const Text(
            'إعدادات خط الأحاديث',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'نوع الخط',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // dropdown below..
                        child: DropdownButton<String>(
                          value: fontFamilySelectedValue,
                          onChanged: (String? newValue) async {
                            await sqlDb.updateData(
                                "UPDATE 'settings' SET 'fontfamily' = '$newValue' WHERE id = 1");
                            fetchData();
                          },
                          items: fontFamilyItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'ثقل الخط',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // dropdown below..
                        child: DropdownButton<String>(
                          value: fontWeightSelectedValue,
                          onChanged: (String? newValue) async {
                            String selectedWeight = '';
                            if (newValue == 'عادي') {
                              selectedWeight = 'normal';
                            } else if (newValue == 'عريض') {
                              selectedWeight = 'bold';
                            }

                            await sqlDb.updateData(
                                "UPDATE 'settings' SET 'fontweight' = '$selectedWeight' WHERE id = 1");
                            fetchData();
                          },
                          items: fontWeightItems
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'حجم الخط',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // dropdown below..
                        child: DropdownButton<int>(
                          value: fontSizeSelectedValue,
                          onChanged: (int? newValue) async {
                            await sqlDb.updateData(
                                "UPDATE 'settings' SET 'fontsize' = $newValue WHERE id = 1");
                            fetchData();
                          },
                          items: fontSizeItems
                              .map<DropdownMenuItem<int>>(
                                  (int value) => DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                          '$value',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
                          underline: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'الحشو',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // dropdown below..
                        child: DropdownButton<int>(
                          value: paddingSelectedValue,
                          onChanged: (int? newValue) async {
                            await sqlDb.updateData(
                                "UPDATE 'settings' SET 'padding' = $newValue WHERE id = 1");
                            fetchData();
                          },
                          items: paddingItems
                              .map<DropdownMenuItem<int>>(
                                  (int value) => DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                          '$value',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                              .toList(),

                          // add extra sugar..
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 42,
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
            height: 30,
          ),
          SizedBox(
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () async {
                await sqlDb.updateData(
                    "UPDATE 'settings' SET 'theme' = 'system', 'fontfamily' = 'Roboto', 'fontweight' = 'normal', 'fontsize' = 20, 'padding' = 10 WHERE id = 1");
                fetchData();
              },
              icon: const Icon(
                Icons.restore_outlined,
                size: 25,
              ),
              label: const Text(
                'العودة للإعدادات الإفتراضية',
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
        ],
      ),
      drawer: const MyNavigationDrawer(),
    );
  }
}
