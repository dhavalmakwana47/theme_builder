import 'package:dio/dio.dart';
import '../../core/network/api_config.dart';
import '../../domain/models/template_model.dart';

class PaginatedTemplatesResponse {
  final List<TemplateModel> templates;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginatedTemplatesResponse({
    required this.templates,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });
}

class TemplateApiService {
  final Dio dio;

  TemplateApiService({Dio? dioClient})
      : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: ApiConfig.defaultHeaders,
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
              ),
            );

  /// Fetch paginated list of templates with optional search query.
  Future<PaginatedTemplatesResponse> fetchTemplates({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final List<String> urlsToTry = [
      ApiConfig.baseUrl,
      'http://127.0.0.1:8000/api/v1',
      'http://localhost:8000/api/v1',
      'https://tournax.in/api/v1',
    ];

    Object? lastError;

    for (final baseUrlStr in urlsToTry) {
      try {
        final client = Dio(BaseOptions(
          baseUrl: baseUrlStr,
          headers: ApiConfig.defaultHeaders,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ));

        final response = await client.get('/templates', queryParameters: queryParams);

        if (response.data is Map && response.data['success'] == true) {
          final resMap = Map<String, dynamic>.from(response.data as Map);
          final dataList = (resMap['data'] is List) ? (resMap['data'] as List) : [];
          final pagMeta = (resMap['pagination'] is Map) ? Map<String, dynamic>.from(resMap['pagination'] as Map) : <String, dynamic>{};

          final templates = dataList
              .whereType<Map>()
              .map((item) => TemplateModel.fromJson(item))
              .toList();

          return PaginatedTemplatesResponse(
            templates: templates,
            currentPage: (pagMeta['current_page'] as num?)?.toInt() ?? page,
            perPage: (pagMeta['per_page'] as num?)?.toInt() ?? perPage,
            total: (pagMeta['total'] as num?)?.toInt() ?? templates.length,
            lastPage: (pagMeta['last_page'] as num?)?.toInt() ?? 1,
          );
        }
      } catch (e) {
        lastError = e;
        print('TemplateApiService failed for URL $baseUrlStr: $e');
      }
    }

    throw Exception(lastError ?? 'Failed to fetch templates from all backend API endpoints');
  }

  /// Get single template by ID.
  Future<TemplateModel> getTemplateById(String id) async {
    final response = await dio.get('/templates/$id');

    if (response.data is Map && response.data['success'] == true) {
      final resMap = Map<String, dynamic>.from(response.data as Map);
      final dataMap = resMap['data'] as Map;
      return TemplateModel.fromJson(dataMap);
    } else {
      throw Exception(response.data?['message'] ?? 'Template not found');
    }
  }

  /// Create a new template on Laravel backend.
  Future<TemplateModel> createTemplate(TemplateModel template, {String? thumbnailBase64}) async {
    final Map<String, dynamic> payload = {
      'name': template.name,
      'width': template.canvasSpec.width.toInt(),
      'height': template.canvasSpec.height.toInt(),
      'layers_count': template.layers.length,
      'json_data': template.toJson(),
    };

    if (thumbnailBase64 != null && thumbnailBase64.isNotEmpty) {
      payload['thumbnail'] = thumbnailBase64;
    } else if (template.thumbnail != null) {
      payload['thumbnail'] = template.thumbnail;
    }

    final response = await dio.post('/templates', data: payload);

    if (response.data is Map && response.data['success'] == true) {
      final resMap = Map<String, dynamic>.from(response.data as Map);
      final dataMap = resMap['data'] as Map;
      return TemplateModel.fromJson(dataMap);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to create template');
    }
  }

  /// Update an existing template on Laravel backend.
  Future<TemplateModel> updateTemplate(String id, TemplateModel template, {String? thumbnailBase64}) async {
    final Map<String, dynamic> payload = {
      'name': template.name,
      'width': template.canvasSpec.width.toInt(),
      'height': template.canvasSpec.height.toInt(),
      'layers_count': template.layers.length,
      'json_data': template.toJson(),
    };

    if (thumbnailBase64 != null && thumbnailBase64.isNotEmpty) {
      payload['thumbnail'] = thumbnailBase64;
    } else if (template.thumbnail != null) {
      payload['thumbnail'] = template.thumbnail;
    }

    final response = await dio.put('/templates/$id', data: payload);

    if (response.data is Map && response.data['success'] == true) {
      final resMap = Map<String, dynamic>.from(response.data as Map);
      final dataMap = resMap['data'] as Map;
      return TemplateModel.fromJson(dataMap);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to update template');
    }
  }

  /// Delete template by ID.
  Future<void> deleteTemplate(String id) async {
    final response = await dio.delete('/templates/$id');

    if (response.data is Map && response.data['success'] == true) {
      return;
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to delete template');
    }
  }

  /// Duplicate template by ID.
  Future<TemplateModel> duplicateTemplate(String id) async {
    final response = await dio.post('/templates/$id/duplicate');

    if (response.data is Map && response.data['success'] == true) {
      final resMap = Map<String, dynamic>.from(response.data as Map);
      final dataMap = resMap['data'] as Map;
      return TemplateModel.fromJson(dataMap);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to duplicate template');
    }
  }

  /// Rename template by ID.
  Future<TemplateModel> renameTemplate(String id, String newName) async {
    final response = await dio.patch(
      '/templates/$id/rename',
      data: {'name': newName},
    );

    if (response.data is Map && response.data['success'] == true) {
      final resMap = Map<String, dynamic>.from(response.data as Map);
      final dataMap = resMap['data'] as Map;
      return TemplateModel.fromJson(dataMap);
    } else {
      throw Exception(response.data?['message'] ?? 'Failed to rename template');
    }
  }
}
