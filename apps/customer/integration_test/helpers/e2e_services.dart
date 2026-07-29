// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class E2EAuthService implements IAuthService {
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted onCompleted,
    required PhoneVerificationFailed onFailed,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeTimeout,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    onCodeSent('e2e-verification-id', null);
  }

  @override
  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    return _E2EUserCredential();
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _E2EUserCredential();
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return _E2EUserCredential();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  String? getPhoneNumber() => '+1234567890';

  void simulateAuthState(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void dispose() {
    _authStateController.close();
  }
}

class _E2EUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class E2EFirestoreService implements IFirestoreService {
  final Map<String, Map<String, dynamic>> _store = {};

  String _docPath(String collection, String docId) => '$collection/$docId';

  @override
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    _store[_docPath(collection, documentId)] = data;
  }

  @override
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final path = _docPath(collection, documentId);
    final existing = _store[path];
    if (existing != null) {
      _store[path] = {...existing, ...data};
    }
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    _store.remove(_docPath(collection, documentId));
  }

  @override
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    final data = _store[_docPath(collection, documentId)];
    return _E2EDocSnapshot(documentId, data, data != null);
  }

  @override
  Future<QuerySnapshot> getDocuments({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    final docs = _store.entries
        .where((e) => e.key.startsWith('$collection/'))
        .map((e) {
      final docId = e.key.split('/').last;
      return _E2EQueryDocSnapshot(docId, e.value);
    }).toList();

    if (limit != null && docs.length > limit) {
      return _E2EQuerySnapshot(docs.sublist(0, limit));
    }
    return _E2EQuerySnapshot(docs);
  }

  @override
  Stream<DocumentSnapshot> watchDocument({
    required String collection,
    required String documentId,
  }) {
    final data = _store[_docPath(collection, documentId)];
    return Stream.value(_E2EDocSnapshot(documentId, data ?? {}, data != null));
  }

  @override
  Stream<QuerySnapshot> watchDocuments({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    final docs = _store.entries
        .where((e) => e.key.startsWith('$collection/'))
        .map((e) {
      final docId = e.key.split('/').last;
      return _E2EQueryDocSnapshot(docId, e.value);
    }).toList();
    return Stream.value(_E2EQuerySnapshot(docs));
  }

  @override
  Future<QuerySnapshot> getDocumentsPaginated({
    required String collection,
    required DocumentSnapshot lastDocument,
    String? orderBy,
    bool descending = false,
    int limit = 20,
  }) async {
    return getDocuments(collection: collection, limit: limit);
  }

  @override
  Future<QuerySnapshot> getDocumentsFilteredPaginated({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    return getDocuments(collection: collection, where: where, limit: limit);
  }

  @override
  Future<void> updateDocuments({
    required String collection,
    required List<String> documentIds,
    required Map<String, dynamic> data,
  }) async {
    for (final docId in documentIds) {
      await updateDocument(collection: collection, documentId: docId, data: data);
    }
  }

  @override
  String newDocumentId({required String collection}) {
    return 'e2e-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _E2EDocSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic>? _data;
  final bool _exists;

  _E2EDocSnapshot(this._id, this._data, this._exists);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _exists;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _E2EQueryDocSnapshot implements QueryDocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  _E2EQueryDocSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;

  @override
  bool get exists => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _E2EQuerySnapshot implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  _E2EQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  int get size => _docs.length;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
