import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/template_repository.dart';
import '../../../domain/models/template_model.dart';
import '../../editor/providers/editor_notifier.dart';

class TemplateListState {
  final List<TemplateModel> templates;
  final bool isLoading;
  final bool isFetchingMore;
  final int currentPage;
  final int lastPage;
  final String searchQuery;
  final String? errorMessage;

  TemplateListState({
    this.templates = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.searchQuery = '',
    this.errorMessage,
  });

  TemplateListState copyWith({
    List<TemplateModel>? templates,
    bool? isLoading,
    bool? isFetchingMore,
    int? currentPage,
    int? lastPage,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TemplateListState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class TemplateListNotifier extends StateNotifier<TemplateListState> {
  final TemplateRepository repository;
  Timer? _debounceTimer;

  TemplateListNotifier(this.repository) : super(TemplateListState()) {
    fetchTemplates();
  }

  /// Initial load or Pull-to-refresh
  Future<void> fetchTemplates({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, currentPage: 1, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final res = await repository.getTemplates(
        page: 1,
        perPage: 20,
        search: state.searchQuery,
      );

      state = state.copyWith(
        templates: res.templates,
        isLoading: false,
        currentPage: res.currentPage,
        lastPage: res.lastPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more items for infinite scroll pagination
  Future<void> loadMore() async {
    if (state.isFetchingMore || state.currentPage >= state.lastPage || state.isLoading) {
      return;
    }

    state = state.copyWith(isFetchingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final res = await repository.getTemplates(
        page: nextPage,
        perPage: 20,
        search: state.searchQuery,
      );

      final combined = List<TemplateModel>.from(state.templates)..addAll(res.templates);

      state = state.copyWith(
        templates: combined,
        isFetchingMore: false,
        currentPage: res.currentPage,
        lastPage: res.lastPage,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false);
    }
  }

  /// Set search query with debounce
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchTemplates(isRefresh: true);
    });
  }

  /// Optimistic delete template
  Future<void> deleteTemplate(String id) async {
    final previousList = List<TemplateModel>.from(state.templates);
    state = state.copyWith(
      templates: state.templates.where((t) => t.id != id).toList(),
    );

    try {
      await repository.deleteTemplate(id);
    } catch (e) {
      // Rollback on error
      state = state.copyWith(
        templates: previousList,
        errorMessage: 'Failed to delete template: $e',
      );
    }
  }

  /// Duplicate template
  Future<void> duplicateTemplate(String id) async {
    try {
      final duplicated = await repository.duplicateTemplate(id);
      state = state.copyWith(
        templates: [duplicated, ...state.templates],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to duplicate template: $e');
    }
  }

  /// Rename template
  Future<void> renameTemplate(String id, String newName) async {
    try {
      final updated = await repository.renameTemplate(id, newName);
      state = state.copyWith(
        templates: state.templates.map((t) => t.id == id ? updated : t).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to rename template: $e');
    }
  }

  /// Save new or existing template and update list
  Future<TemplateModel?> saveTemplate(TemplateModel template, {String? thumbnailBase64}) async {
    try {
      final saved = await repository.saveTemplate(template, thumbnailBase64: thumbnailBase64);
      final index = state.templates.indexWhere((t) => t.id == saved.id);
      if (index >= 0) {
        final updatedList = List<TemplateModel>.from(state.templates);
        updatedList[index] = saved;
        state = state.copyWith(templates: updatedList);
      } else {
        state = state.copyWith(templates: [saved, ...state.templates]);
      }
      return saved;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save template: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final templateListProvider =
    StateNotifierProvider<TemplateListNotifier, TemplateListState>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return TemplateListNotifier(repository);
});
