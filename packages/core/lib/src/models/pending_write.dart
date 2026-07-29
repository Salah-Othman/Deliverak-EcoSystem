enum PendingWriteStatus { pending, inProgress, completed, failed }

class PendingWrite {
  final String id;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final String operation; // 'set', 'update', 'delete'
  final PendingWriteStatus status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;

  const PendingWrite({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.operation,
    this.status = PendingWriteStatus.pending,
    this.retryCount = 0,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  PendingWrite copyWith({
    PendingWriteStatus? status,
    int? retryCount,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return PendingWrite(
      id: id,
      collection: collection,
      documentId: documentId,
      data: data,
      operation: operation,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'operation': operation,
      'status': status.name,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory PendingWrite.fromMap(Map<String, dynamic> map) {
    return PendingWrite(
      id: map['id'] as String? ?? '',
      collection: map['collection'] as String? ?? '',
      documentId: map['documentId'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      operation: map['operation'] as String? ?? 'set',
      status: PendingWriteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PendingWriteStatus.pending,
      ),
      retryCount: map['retryCount'] as int? ?? 0,
      createdAt: DateTime.parse(
        map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'] as String)
          : null,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
