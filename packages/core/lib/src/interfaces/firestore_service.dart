import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFirestoreService {
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  });

  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  });

  Future<QuerySnapshot> getDocuments({
    required String collection,
    List<List<dynamic>>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Stream<DocumentSnapshot> watchDocument({
    required String collection,
    required String documentId,
  });

  Stream<QuerySnapshot> watchDocuments({
    required String collection,
    List<List<dynamic>>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  Future<QuerySnapshot> getDocumentsPaginated({
    required String collection,
    required DocumentSnapshot lastDocument,
    String? orderBy,
    bool descending = false,
    int limit = 20,
  });
}
