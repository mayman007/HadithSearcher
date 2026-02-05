import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

/// ViewModel for favourites view.
class FavouritesViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ApiService _api = ApiService();

  List<FavouriteHadith> _favourites = [];
  bool _isLoading = true;

  /// List of favourited hadiths.
  List<FavouriteHadith> get favourites => _favourites;

  /// Whether data is loading.
  bool get isLoading => _isLoading;

  /// Whether favourites list is empty.
  bool get isEmpty => _favourites.isEmpty && !_isLoading;

  /// Whether there are favourites.
  bool get hasFavourites => _favourites.isNotEmpty;

  /// Load all favourites from database.
  Future<void> loadFavourites() async {
    _isLoading = true;
    notifyListeners();

    _favourites = await _db.getFavourites();

    _isLoading = false;
    notifyListeners();
  }

  /// Remove a hadith from favourites.
  Future<void> removeFavourite(String hadithId) async {
    await _db.removeFavourite(hadithId);
    _favourites.removeWhere((f) => f.hadithId == hadithId);
    notifyListeners();
  }

  /// Get sharh (explanation) for a hadith.
  Future<ApiResult<String>> getSharh(String hadithId) async {
    // First get the full hadith to check for sharh metadata
    final hadithResult = await _api.getHadithById(hadithId);

    if (hadithResult.isError) {
      return ApiResult.error(hadithResult.error!);
    }

    final hadith = hadithResult.data!;
    if (!hadith.hasSharhMetadata || hadith.sharhId == null) {
      return ApiResult.error(ApiError.notFound);
    }

    return _api.getSharh(hadith.sharhId!);
  }
}
