// ignore_for_file: subtype_of_sealed_class
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

class MockFirestoreService extends Mock implements IFirestoreService {}

class MockCacheService extends Mock implements ICacheService {}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool _exists;
  final String _id;

  FakeDocumentSnapshot(this._data, {String? id, bool exists = true})
      : _exists = exists,
        _id = id ?? (_data['uid'] ?? 'unknown');

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;
}

class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeQueryDocumentSnapshot(this._data, {String? id})
      : _id = id ?? (_data['uid'] ?? 'unknown');

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;
}

class FakeQuerySnapshot extends Fake implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  FakeQuerySnapshot(List<DocumentSnapshot> docs)
      : _docs = docs
            .map((d) => FakeQueryDocumentSnapshot(
                  d.data() as Map<String, dynamic>,
                  id: d.id,
                ))
            .toList();

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  int get size => _docs.length;
}
