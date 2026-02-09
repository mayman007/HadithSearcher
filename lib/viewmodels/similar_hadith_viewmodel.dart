import 'package:flutter/material.dart';
import '../models/hadith.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

/// ViewModel for similar hadith view.
class SimilarHadithViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService();

  List<Hadith> _results = [];
  Set<String> _favouriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  /// Similar hadiths results.
  List<Hadith> get results => _results;

  /// Whether data is loading.
  bool get isLoading => _isLoading;

  /// Error message if any.
  String? get errorMessage => _errorMessage;

  /// Whether results are empty.
  bool get isEmpty => _results.isEmpty && !_isLoading;

  /// Whether there are results.
  bool get hasResults => _results.isNotEmpty;

  /// Check if a hadith is favourited.
  bool isFavourite(String hadithId) => _favouriteIds.contains(hadithId);

  /// Load similar hadiths for the given hadith ID.
  Future<void> loadSimilarHadith(String hadithId) async {
    _isLoading = true;
    _errorMessage = null;
    _results = [];
    notifyListeners();

    await _loadFavouriteIds();
    final result = await _api.getSimilarHadith(hadithId);

    if (result.isSuccess) {
      _results = result.data!;
      if (_results.isEmpty) {
        _errorMessage = 'noSimilar';
      }
    } else {
      _errorMessage = result.error!.arabicTitle;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load favourite IDs for checking.
  Future<void> _loadFavouriteIds() async {
    _favouriteIds = await _db.getFavouriteIds();
  }

  /// Toggle favourite status for a hadith.
  Future<String?> toggleFavourite(Hadith hadith) async {
    if (_favouriteIds.contains(hadith.id)) {
      final success = await _db.removeFavourite(hadith.id);
      if (success) {
        _favouriteIds.remove(hadith.id);
        notifyListeners();
        return null;
      } else {
        return 'فشل إزالة الحديث من المفضلة';
      }
    } else {
      final success = await _db.addFavourite(
        hadithId: hadith.id,
        hadithText: hadith.text,
        hadithInfo: hadith.formattedInfo,
      );
      if (success) {
        _favouriteIds.add(hadith.id);
        notifyListeners();
        return null;
      } else {
        return 'فشل إضافة الحديث للمفضلة';
      }
    }
  }

  /// Get sharh (explanation) for a hadith.
  Future<ApiResult<String>> getSharh(Hadith hadith) async {
    if (!hadith.hasSharhMetadata || hadith.sharhId == null) {
      return ApiResult.error(ApiError.notFound);
    }
    return _api.getSharh(hadith.sharhId!);
  }
}
