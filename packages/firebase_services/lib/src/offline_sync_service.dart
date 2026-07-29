import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

class OfflineSyncService {
  final FirebaseFirestore _firestore;
  final ICacheService _cache;
  final ICrashlyticsService _crashlytics;
  final String _boxName = 'pending_writes';
  static const int _maxRetries = 3;

  List<PendingWrite> _pendingWrites = [];

  OfflineSyncService({
    required ICacheService cache,
    required ICrashlyticsService crashlytics,
    FirebaseFirestore? firestore,
  })  : _cache = cache,
        _crashlytics = crashlytics,
        _firestore = firestore ?? FirebaseFirestore.instance;

  List<PendingWrite> get pendingWrites => List.unmodifiable(_pendingWrites);

  bool get hasPendingWrites => _pendingWrites.isNotEmpty;

  int get pendingCount => _pendingWrites.length;

  Future<void> initialize() async {
    await _loadPendingWrites();
  }

  Future<void> addPendingWrite({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required String operation,
  }) async {
    final pendingWrite = PendingWrite(
      id: _generateId(),
      collection: collection,
      documentId: documentId,
      data: data,
      operation: operation,
      createdAt: DateTime.now(),
    );

    _pendingWrites.add(pendingWrite);
    await _savePendingWrites();

    await _crashlytics.log(
      'Offline write queued: $operation on $collection/$documentId',
    );
  }

  Future<void> syncPendingWrites() async {
    if (_pendingWrites.isEmpty) return;

    final toSync = List<PendingWrite>.from(_pendingWrites)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final write in toSync) {
      if (write.retryCount >= _maxRetries) {
        await _removePendingWrite(write.id);
        await _crashlytics.recordError(
          Exception('Max retries exceeded for pending write'),
          null,
          reason:
              'Failed to sync ${write.operation} on ${write.collection}/${write.documentId} after ${write.retryCount} retries',
          information: {'writeId': write.id, 'operation': write.operation},
        );
        continue;
      }

      try {
        _pendingWrites = _pendingWrites
            .map((w) =>
                w.id == write.id ? w.copyWith(status: PendingWriteStatus.inProgress) : w)
            .toList();
        await _savePendingWrites();

        await _executeWrite(write);

        _pendingWrites = _pendingWrites
            .map((w) =>
                w.id == write.id ? w.copyWith(status: PendingWriteStatus.completed) : w)
            .toList();
        await _savePendingWrites();
        await _removePendingWrite(write.id);

        await _crashlytics.log(
          'Offline write synced: ${write.operation} on ${write.collection}/${write.documentId}',
        );
      } catch (e, stackTrace) {
        _pendingWrites = _pendingWrites
            .map((w) => w.id == write.id
                ? w.copyWith(
                    status: PendingWriteStatus.failed,
                    retryCount: w.retryCount + 1,
                    lastAttemptAt: DateTime.now(),
                    errorMessage: e.toString(),
                  )
                : w)
            .toList();
        await _savePendingWrites();

        await _crashlytics.recordError(
          e,
          stackTrace,
          reason: 'Failed to sync pending write',
          information: {
            'writeId': write.id,
            'operation': write.operation,
            'collection': write.collection,
            'retryCount': write.retryCount + 1,
          },
        );
      }
    }

    _pendingWrites.removeWhere(
      (w) => w.status == PendingWriteStatus.completed,
    );
    await _savePendingWrites();
  }

  Future<void> _executeWrite(PendingWrite write) async {
    final docRef = _firestore.collection(write.collection).doc(write.documentId);

    switch (write.operation) {
      case 'set':
        await docRef.set(write.data);
        break;
      case 'update':
        await docRef.update(write.data);
        break;
      case 'delete':
        await docRef.delete();
        break;
    }
  }

  Future<void> retryPendingWrite(String writeId) async {
    final index = _pendingWrites.indexWhere((w) => w.id == writeId);
    if (index == -1) return;

    final write = _pendingWrites[index];
    _pendingWrites[index] = write.copyWith(
      status: PendingWriteStatus.pending,
      retryCount: 0,
      errorMessage: null,
    );
    await _savePendingWrites();
  }

  Future<void> removePendingWrite(String writeId) async {
    await _removePendingWrite(writeId);
  }

  Future<void> clearAllPendingWrites() async {
    _pendingWrites.clear();
    await _savePendingWrites();
  }

  Future<void> _loadPendingWrites() async {
    final data = _cache.get<String>(_boxName, 'pending_writes_list');
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _pendingWrites = jsonList
            .map((e) => PendingWrite.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _pendingWrites = [];
      }
    }
  }

  Future<void> _savePendingWrites() async {
    final jsonList = _pendingWrites.map((w) => w.toMap()).toList();
    await _cache.put<String>(
      _boxName,
      'pending_writes_list',
      jsonEncode(jsonList),
    );
  }

  Future<void> _removePendingWrite(String writeId) async {
    _pendingWrites.removeWhere((w) => w.id == writeId);
    await _savePendingWrites();
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'pw_${timestamp}_$random';
  }
}
