import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    this.lastDocument,
    required this.hasMore,
  });

  PaginatedResult.empty()
      : items = const [],
        lastDocument = null,
        hasMore = false;

  PaginatedResult<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  PaginatedResult<T> append(PaginatedResult<T> next) {
    return PaginatedResult<T>(
      items: [...items, ...next.items],
      lastDocument: next.lastDocument,
      hasMore: next.hasMore,
    );
  }
}
