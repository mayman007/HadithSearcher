import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith.dart';
import '../models/search_params.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

/// ViewModel for hadith search functionality.
class SearchViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService();

  // Search state
  List<Hadith> _results = [];
  Set<String> _favouriteIds = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreResults = true;
  String? _errorMessage;
  SearchParams? _currentParams;

  // Advanced search state
  bool _isAdvancedSearchOpen = false;
  SearchWay _searchWay = SearchWay.anyWord;
  SearchRange _searchRange = SearchRange.all;
  SearchGrade _searchGrade = SearchGrade.all;
  SearchMohdith _searchMohdith = SearchMohdith.all;
  SearchBook _searchBook = SearchBook.all;
  String _excludedWords = '';
  bool _saveAdvancedSettings = true;
  String _searchQuery = '';

  // Getters
  List<Hadith> get results => _results;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreResults => _hasMoreResults;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _results.isEmpty && !_isLoading;
  bool get hasResults => _results.isNotEmpty;

  // Advanced search getters
  bool get isAdvancedSearchOpen => _isAdvancedSearchOpen;
  SearchWay get searchWay => _searchWay;
  SearchRange get searchRange => _searchRange;
  SearchGrade get searchGrade => _searchGrade;
  SearchMohdith get searchMohdith => _searchMohdith;
  SearchBook get searchBook => _searchBook;
  String get excludedWords => _excludedWords;
  bool get saveAdvancedSettings => _saveAdvancedSettings;
  String get searchQuery => _searchQuery;

  /// Initialize by loading saved preferences.
  Future<void> init() async {
    await _loadAdvancedPrefs();
    await _loadFavouriteIds();
  }

  /// Load saved advanced search preferences.
  Future<void> _loadAdvancedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final wayStr = prefs.getString('searchWay');
    if (wayStr != null) {
      _searchWay = SearchWay.fromArabic(wayStr);
    }

    final rangeStr = prefs.getString('searchRange');
    if (rangeStr != null) {
      _searchRange = SearchRange.fromArabic(rangeStr);
    }

    final gradeStr = prefs.getString('searchGrade');
    if (gradeStr != null) {
      _searchGrade = SearchGrade.fromArabic(gradeStr);
    }

    final mohdithStr = prefs.getString('searchMohdith');
    if (mohdithStr != null) {
      _searchMohdith = SearchMohdith.fromArabic(mohdithStr);
    }

    final bookStr = prefs.getString('searchBook');
    if (bookStr != null) {
      _searchBook = SearchBook.fromArabic(bookStr);
    }

    _excludedWords = prefs.getString('searchExcludedWords') ?? '';
    _saveAdvancedSettings = prefs.getBool('advancedSaveCheckbox') ?? true;
    _searchQuery = prefs.getString('searchQuery') ?? '';

    notifyListeners();
  }

  /// Load favourite hadith IDs for checking.
  Future<void> _loadFavouriteIds() async {
    _favouriteIds = await _db.getFavouriteIds();
  }

  /// Check if a hadith is favourited.
  bool isFavourite(String hadithId) => _favouriteIds.contains(hadithId);

  /// Search for hadiths with given keyword.
  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      _errorMessage = 'emptySearch';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _results = [];
    _hasMoreResults = true;
    notifyListeners();

    _currentParams = SearchParams(
      keyword: keyword,
      page: 1,
      searchWay: _searchWay,
      searchRange: _searchRange,
      searchGrade: _searchGrade,
      searchMohdith: _searchMohdith,
      searchBook: _searchBook,
      excludedWords: _excludedWords,
    );

    final result = await _api.searchHadith(_currentParams!);

    if (result.isSuccess) {
      _results = result.data!;
      _hasMoreResults = result.data!.length >= 30; // API returns 30 per page
      await _loadFavouriteIds();

      if (_results.isEmpty) {
        _errorMessage = 'noResults';
      }
    } else {
      _errorMessage = result.error!.arabicTitle;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more results (pagination).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMoreResults || _currentParams == null) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentParams = _currentParams!.nextPage();
    final result = await _api.searchHadith(_currentParams!);

    if (result.isSuccess) {
      if (result.data!.isEmpty) {
        _hasMoreResults = false;
      } else {
        _results.addAll(result.data!);
        _hasMoreResults = result.data!.length >= 30;
      }
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Toggle favourite status for a hadith.
  Future<void> toggleFavourite(Hadith hadith) async {
    if (_favouriteIds.contains(hadith.id)) {
      await _db.removeFavourite(hadith.id);
      _favouriteIds.remove(hadith.id);
    } else {
      await _db.addFavourite(
        hadithId: hadith.id,
        hadithText: hadith.text,
        hadithInfo: hadith.formattedInfo,
      );
      _favouriteIds.add(hadith.id);
    }
    notifyListeners();
  }

  /// Toggle advanced search panel.
  void toggleAdvancedSearch() {
    _isAdvancedSearchOpen = !_isAdvancedSearchOpen;
    notifyListeners();
  }

  /// Close advanced search panel.
  void closeAdvancedSearch() {
    _isAdvancedSearchOpen = false;
    notifyListeners();
  }

  // Advanced search setters
  void setSearchWay(SearchWay value) {
    _searchWay = value;
    notifyListeners();
  }

  void setSearchRange(SearchRange value) {
    _searchRange = value;
    notifyListeners();
  }

  void setSearchGrade(SearchGrade value) {
    _searchGrade = value;
    notifyListeners();
  }

  void setSearchMohdith(SearchMohdith value) {
    _searchMohdith = value;
    notifyListeners();
  }

  void setSearchBook(SearchBook value) {
    _searchBook = value;
    notifyListeners();
  }

  void setExcludedWords(String value) {
    _excludedWords = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    // Don't notify listeners to avoid rebuild during typing
  }

  void setSaveAdvancedSettings(bool value) {
    _saveAdvancedSettings = value;
    notifyListeners();
  }

  /// Save advanced search settings if enabled.
  Future<void> saveAdvancedPrefs() async {
    if (!_saveAdvancedSettings) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('searchWay', _searchWay.arabicName);
    await prefs.setString('searchRange', _searchRange.arabicName);
    await prefs.setString('searchGrade', _searchGrade.arabicName);
    await prefs.setString('searchMohdith', _searchMohdith.arabicName);
    await prefs.setString('searchBook', _searchBook.arabicName);
    await prefs.setString('searchExcludedWords', _excludedWords);
    await prefs.setBool('advancedSaveCheckbox', _saveAdvancedSettings);
    await prefs.setString('searchQuery', _searchQuery);
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
