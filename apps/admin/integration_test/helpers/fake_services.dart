// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakeAuthService implements IAuthService {
  final _authStateController = StreamController<User?>.broadcast();
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  void simulateSignIn({String uid = 'admin-uid-1', String? email}) {
    _user = _FakeUser(uid: uid, email: email ?? 'admin@test.com');
    _authStateController.add(_user);
  }

  void simulateSignOut() {
    _user = null;
    _authStateController.add(null);
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    simulateSignIn(email: email);
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password,
      {String? name}) async {
    simulateSignIn(email: email);
    return _FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    simulateSignOut();
  }

  @override
  String? getPhoneNumber() => null;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted onCompleted,
    required PhoneVerificationFailed onFailed,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeTimeout,
  }) async {}

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return _FakeUserCredential();
  }

  void dispose() {
    _authStateController.close();
  }
}

class _FakeUser implements User {
  final String _uid;
  final String _email;

  _FakeUser({required String uid, required String email})
      : _uid = uid,
        _email = email;

  @override
  String get uid => _uid;
  @override
  String? get email => _email;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeFirestoreService implements IFirestoreService {
  final Map<String, Map<String, dynamic>> _store = {};
  final _controllers = <String, StreamController<Map<String, dynamic>?>>{};

  String _docPath(String collection, String docId) => '$collection/$docId';

  @override
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final path = _docPath(collection, documentId);
    _store[path] = data;
    _notifyWatchers(path, data);
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
      _notifyWatchers(path, _store[path]);
    }
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    final path = _docPath(collection, documentId);
    _store.remove(path);
    _notifyWatchers(path, null);
  }

  @override
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    final path = _docPath(collection, documentId);
    final data = _store[path];
    return _FakeDocSnapshot(documentId, data, data != null);
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
      return _FakeQueryDocSnapshot(docId, e.value);
    }).toList();

    if (limit != null && docs.length > limit) {
      return _FakeQuerySnapshot(docs.sublist(0, limit));
    }
    return _FakeQuerySnapshot(docs);
  }

  @override
  Stream<DocumentSnapshot> watchDocument({
    required String collection,
    required String documentId,
  }) {
    final path = _docPath(collection, documentId);
    final controller = StreamController<Map<String, dynamic>?>.broadcast();
    _controllers[path] = controller;
    final initialData = _store[path];
    controller.add(initialData);
    return controller.stream.map(
        (data) => _FakeDocSnapshot(documentId, data ?? {}, data != null));
  }

  @override
  Stream<QuerySnapshot> watchDocuments({
    required String collection,
    List<QueryCondition>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    final controller = StreamController<QuerySnapshot>.broadcast();
    void emitCurrent() {
      final docs = _store.entries
          .where((e) => e.key.startsWith('$collection/'))
          .map((e) {
        final docId = e.key.split('/').last;
        return _FakeQueryDocSnapshot(docId, e.value);
      }).toList();
      controller.add(_FakeQuerySnapshot(docs));
    }

    emitCurrent();
    _controllers['watch_$collection'] =
        StreamController<Map<String, dynamic>?>.broadcast()
          ..stream.listen((_) => emitCurrent());

    return controller.stream;
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
    return 'doc-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _notifyWatchers(String path, Map<String, dynamic>? data) {
    final controller = _controllers[path];
    if (controller != null && !controller.isClosed) {
      controller.add(data);
    }
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
  }
}

class FakeSecureStorageService implements ISecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();
}

class FakeCacheService implements ICacheService {
  final Map<String, Map<String, dynamic>> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>(String box, String key, T value) async {
    _store.putIfAbsent(box, () => {});
    _store[box]![key] = value;
  }

  @override
  T? get<T>(String box, String key) => _store[box]?[key] as T?;

  @override
  Future<void> delete(String box, String key) async => _store[box]?.remove(key);

  @override
  Future<void> clearBox(String box) async => _store.remove(box);

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  bool containsKey(String box, String key) =>
      _store[box]?.containsKey(key) ?? false;
}

class _FakeDocSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic>? _data;
  final bool _exists;

  _FakeDocSnapshot(this._id, this._data, this._exists);

  @override
  String get id => _id;
  @override
  Map<String, dynamic>? data() => _data;
  @override
  bool get exists => _exists;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeQueryDocSnapshot implements QueryDocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  _FakeQueryDocSnapshot(this._id, this._data);

  @override
  String get id => _id;
  @override
  Map<String, dynamic> data() => _data;
  @override
  bool get exists => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeQuerySnapshot implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  _FakeQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;
  @override
  int get size => _docs.length;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
