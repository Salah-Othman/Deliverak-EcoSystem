import 'package:core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(documentId).set(data);
  }

  @override
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  @override
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  Query _buildQuery(
    String collection, {
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (where != null) {
      for (final condition in where) {
        switch (condition.operator) {
          case QueryOperator.isEqualTo:
            query = query.where(condition.field, isEqualTo: condition.value);
          case QueryOperator.isNotEqualTo:
            query = query.where(condition.field, isNotEqualTo: condition.value);
          case QueryOperator.isLessThan:
            query = query.where(condition.field, isLessThan: condition.value);
          case QueryOperator.isLessThanOrEqualTo:
            query = query.where(
              condition.field,
              isLessThanOrEqualTo: condition.value,
            );
          case QueryOperator.isGreaterThan:
            query = query.where(condition.field, isGreaterThan: condition.value);
          case QueryOperator.isGreaterThanOrEqualTo:
            query = query.where(
              condition.field,
              isGreaterThanOrEqualTo: condition.value,
            );
          case QueryOperator.arrayContains:
            query = query.where(
              condition.field,
              arrayContains: condition.value,
            );
        }
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  @override
  Future<QuerySnapshot> getDocuments({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    final query = _buildQuery(
      collection,
      where: where,
      orderBy: orderBy,
      descending: descending,
      limit: limit,
    );
    return await query.get();
  }

  @override
  Stream<DocumentSnapshot> watchDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  @override
  Stream<QuerySnapshot> watchDocuments({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    final query = _buildQuery(
      collection,
      where: where,
      orderBy: orderBy,
      descending: descending,
      limit: limit,
    );
    return query.snapshots();
  }

  @override
  Future<QuerySnapshot> getDocumentsPaginated({
    required String collection,
    required DocumentSnapshot lastDocument,
    String? orderBy,
    bool descending = false,
    int limit = 20,
  }) async {
    Query query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    query = query.startAfterDocument(lastDocument).limit(limit);

    return await query.get();
  }
}
