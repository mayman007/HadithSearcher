import 'package:flutter/material.dart';
import 'package:hadithsearcher/views/search_view.dart';
import '../utilities/show_navigation_drawer.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حول'),
        ),
        body: Center(
          child: Column(
            children: [
              const Text(
                'Hadith Searcher',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'version 1.0.0',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Text(
                      'تطبيق Hadith Searcher يهدف إلي تسهيل البحث عن الأحاديث والتحقق منها.\nجميع الأحاديث والمعلومات مأخوذة من موقع dorar.net.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        iconSize: 35,
                        tooltip: 'الكود المصدري',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.code,
                        ),
                      ),
                      const Text('الكود المصدري'),
                    ],
                  ),
                  const SizedBox(
                    width: 37,
                  ),
                  Column(
                    children: [
                      IconButton(
                        iconSize: 35,
                        tooltip: 'إبلاغ عن مشكلة',
                        onPressed: () {},
                        icon: const Icon(
                          Icons.bug_report,
                        ),
                      ),
                      const Text('إبلاغ عن مشكلة'),
                    ],
                  ),
                  const SizedBox(
                    width: 37,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'المطور: ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'محمد أيمن',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'https://github.com/Shinobi7k',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: const MyNavigationDrawer(),
      ),
    );
  }
}
