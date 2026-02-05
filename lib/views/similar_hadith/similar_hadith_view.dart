import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/similar_hadith_viewmodel.dart';
import '../../widgets/back_to_top_button.dart';
import '../../widgets/hadith_card.dart';

class SimilarHadithView extends StatefulWidget {
  final String? hadithId;

  const SimilarHadithView({super.key, this.hadithId});

  @override
  State<SimilarHadithView> createState() => _SimilarHadithViewState();
}

class _SimilarHadithViewState extends State<SimilarHadithView>
    with ScrollToTopMixin {
  @override
  void initState() {
    super.initState();
    initScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hadithId != null) {
        context
            .read<SimilarHadithViewModel>()
            .loadSimilarHadith(widget.hadithId!);
      }
    });
  }

  @override
  void dispose() {
    disposeScrollController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SimilarHadithViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('أحاديث مشابهة')),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : vm.isEmpty
                ? _buildEmptyState(vm)
                : _buildResults(vm),
      ),
      floatingActionButton: buildBackToTopButton(),
    );
  }

  Widget _buildEmptyState(SimilarHadithViewModel vm) {
    if (vm.errorMessage == 'noSimilar') {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_paste_off, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'لا توجد أحاديث مشابهة',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ],
      );
    }

    if (vm.errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            vm.errorMessage!,
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResults(SimilarHadithViewModel vm) {
    return ListView.builder(
      controller: scrollController,
      itemCount: vm.results.length,
      itemBuilder: (context, index) {
        final hadith = vm.results[index];
        return HadithCard(
          hadith: hadith,
          isFavourite: vm.isFavourite(hadith.id),
          showSimilarButton: false, // Don't show similar button in similar view
          onFavouriteToggle: () => vm.toggleFavourite(hadith),
        );
      },
    ).animate().fade(duration: 200.ms);
  }
}
