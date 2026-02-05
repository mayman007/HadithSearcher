import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/hadith.dart';
import '../models/search_params.dart';

/// Service for making API calls to the Hadith API.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl => dotenv.env['HADITH_API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 24);
  static const Duration _shortTimeout = Duration(seconds: 8);

  /// Search for hadiths with given parameters.
  Future<ApiResult<List<Hadith>>> searchHadith(SearchParams params) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/v1/site/hadith/search?${params.toQueryString()}',
      );

      final response = await http.get(url).timeout(_timeout);
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedBody);

      if (jsonResponse['metadata']['length'] == 0) {
        return ApiResult.success([]);
      }

      final hadiths = (jsonResponse['data'] as List)
          .map((h) => Hadith.fromJson(h))
          .toList();

      return ApiResult.success(hadiths);
    } on http.ClientException {
      return ApiResult.error(ApiError.noConnection);
    } on TimeoutException {
      return ApiResult.error(ApiError.timeout);
    } catch (e) {
      return ApiResult.error(ApiError.unknown);
    }
  }

  /// Get similar hadiths for a given hadith ID.
  Future<ApiResult<List<Hadith>>> getSimilarHadith(String hadithId) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/site/hadith/similar/$hadithId');

      final response = await http.get(url).timeout(_timeout);
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedBody);

      if (jsonResponse['metadata']['length'] == 0) {
        return ApiResult.success([]);
      }

      final hadiths = (jsonResponse['data'] as List)
          .map((h) => Hadith.fromJson(h))
          .toList();

      return ApiResult.success(hadiths);
    } on http.ClientException {
      return ApiResult.error(ApiError.noConnection);
    } on TimeoutException {
      return ApiResult.error(ApiError.timeout);
    } catch (e) {
      return ApiResult.error(ApiError.unknown);
    }
  }

  /// Get explanation (sharh) for a hadith.
  Future<ApiResult<String>> getSharh(String sharhId) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/site/sharh/$sharhId');

      final response = await http.get(url).timeout(_shortTimeout);
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedBody);

      final sharh = jsonResponse['data']?['sharhMetadata']?['sharh'] as String?;

      if (sharh == null || sharh.isEmpty) {
        return ApiResult.error(ApiError.notFound);
      }

      return ApiResult.success(sharh);
    } on http.ClientException {
      return ApiResult.error(ApiError.noConnection);
    } on TimeoutException {
      return ApiResult.error(ApiError.timeout);
    } catch (e) {
      return ApiResult.error(ApiError.unknown);
    }
  }

  /// Get hadith by ID (used for favourites to get full metadata).
  Future<ApiResult<Hadith>> getHadithById(String hadithId) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/site/hadith/$hadithId');

      final response = await http.get(url).timeout(_shortTimeout);
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedBody);

      if (jsonResponse['data'] == null) {
        return ApiResult.error(ApiError.notFound);
      }

      return ApiResult.success(Hadith.fromJson(jsonResponse['data']));
    } on http.ClientException {
      return ApiResult.error(ApiError.noConnection);
    } on TimeoutException {
      return ApiResult.error(ApiError.timeout);
    } catch (e) {
      return ApiResult.error(ApiError.unknown);
    }
  }
}

/// Result wrapper for API calls.
class ApiResult<T> {
  final T? data;
  final ApiError? error;

  ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.error(ApiError error) => ApiResult._(error: error);

  bool get isSuccess => error == null;
  bool get isError => error != null;
}

/// API error types.
enum ApiError {
  noConnection,
  timeout,
  notFound,
  unknown;

  /// Arabic error title.
  String get arabicTitle {
    switch (this) {
      case ApiError.noConnection:
        return 'خطأ بالإتصال بالإنترنت';
      case ApiError.timeout:
        return 'نفذ الوقت';
      case ApiError.notFound:
        return 'لا توجد نتائج';
      case ApiError.unknown:
        return 'خطأ غير متوقع';
    }
  }

  /// Arabic error description.
  String get arabicDescription {
    switch (this) {
      case ApiError.noConnection:
        return 'تأكد من إتصالك بالإنترنت وأعد المحاولة';
      case ApiError.timeout:
        return 'تأكد من إتصالك بإنترنت مستقر وأعد المحاولة';
      case ApiError.notFound:
        return 'استخدم كلمات أو إعدادات أخرى';
      case ApiError.unknown:
        return 'حدث خطأ غير متوقع، حاول مرة أخرى';
    }
  }
}
