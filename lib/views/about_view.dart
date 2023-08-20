import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/routes.dart';
import '../utilities/show_navigation_drawer.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  Future<bool> _onBackPressed() async {
    Navigator.of(context).pushNamedAndRemoveUntil(
      searchRoute,
      (route) => false,
    );
    return true;
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حول'),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                  child: const Text(
                    'تطبيق Hadith Searcher يهدف إلي تسهيل البحث عن الأحاديث والتحقق منها.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
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
                      const Text(
                        'جميع الأحاديث والمعلومات مأخوذة من موقع dorar.net بإستخدام API AhmedElTabarani.',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        child: const Text(
                          'dorar.net',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          _launchUrl(Uri.parse('https://dorar.net/'));
                        },
                      ),
                      GestureDetector(
                        child: const Text(
                          'AhmedElTabarani API',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          _launchUrl(Uri.parse(
                              'https://github.com/AhmedElTabarani/dorar-hadith-api'));
                        },
                      )
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  thickness: 2,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                      GestureDetector(
                        child: const Text(
                          'https://github.com/Shinobi7k',
                          style: TextStyle(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          _launchUrl(Uri.parse('https://github.com/Shinobi7k'));
                        },
                      ),
                      GestureDetector(
                        child: const Text(
                          'mohamedayman011324@gmail.com',
                          style: TextStyle(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          _launchUrl(Uri.parse('mohamedayman011324@gmail.com'));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: const MyNavigationDrawer(),
      ),
    );
  }
}
