import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'حول',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      )),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Text(
                'Hadith Searcher',
                style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text('الإصدار 2.0.0', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _buildInfoCard(
                context,
                'تطبيق Hadith Searcher هو تطبيق شامل للبحث في آلاف الأحاديث النبوية الشريفة. يوفر إمكانيات بحث وتصفية متقدمة حسب الراوي أو درجة صحة الحديث، مع عرض تفصيلي للمعلومات المتعلقة بسند الحديث.',
              ),
              _buildApiInfoCard(context),
              const SizedBox(height: 15),
              _buildActionButtons(context),
              const SizedBox(height: 30),
              _buildDeveloperSection(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildApiInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'جميع الأحاديث والمعلومات مأخوذة من موقع dorar.net باستخدام API AhmedElTabarani.',
            style: TextStyle(fontSize: 18),
          ),
          GestureDetector(
            onTap: () => _launchUrl(Uri.parse('https://dorar.net/')),
            child: const Text(
              'dorar.net',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _launchUrl(Uri.parse(
                'https://github.com/AhmedElTabarani/dorar-hadith-api')),
            child: const Text(
              'AhmedElTabarani API',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionIconButton(
          icon: Icons.share_rounded,
          label: 'مشاركة',
          onTap: () async {
            await SharePlus.instance.share(ShareParams(
              text:
                  'https://play.google.com/store/apps/details?id=com.moaymandev.hadithsearcher',
            ));
          },
        ),
        const SizedBox(width: 40),
        _ActionIconButton(
          icon: Icons.code_rounded,
          label: 'الكود',
          onTap: () => _launchUrl(
              Uri.parse('https://github.com/MAymanKH/HadithSearcher')),
        ),
        const SizedBox(width: 40),
        _ActionIconButton(
          icon: Icons.attach_money_rounded,
          label: 'دعم',
          onTap: () => _launchUrl(Uri.parse('https://ko-fi.com/MAymanKH')),
        ),
      ],
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'تواصل مع المطور',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionIconButton(
              icon: Icons.language,
              label: 'الموقع',
              onTap: () => _launchUrl(Uri.parse('https://mohamedayman.net')),
            ),
            const SizedBox(width: 40),
            _ActionIconButton(
              icon: Icons.email,
              label: 'البريد',
              onTap: () => _launchUrl(Uri.parse('mailto:moaymandev@gmail.com')),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon),
            tooltip: label,
            iconSize: 33,
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
