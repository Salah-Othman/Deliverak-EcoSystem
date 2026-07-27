import 'package:core/core.dart';

class UserRepository implements IUserRepository {
  final IFirestoreService _firestoreService;

  UserRepository({required IFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<UserModel>> getUsers({UserRole? role}) async {
    final conditions = <QueryCondition>[];
    if (role != null) {
      conditions.add(QueryCondition(field: 'role', value: role.name));
    }

    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.users,
      where: conditions.isNotEmpty ? conditions : null,
      orderBy: 'createdAt',
      descending: true,
    );

    return docs.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.users,
      documentId: uid,
    );

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Stream<List<UserModel>> watchUsers({UserRole? role}) {
    final conditions = <QueryCondition>[];
    if (role != null) {
      conditions.add(QueryCondition(field: 'role', value: role.name));
    }

    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.users,
          where: conditions.isNotEmpty ? conditions : null,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<int> getUsersCount() async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.users,
    );
    return docs.size;
  }

  @override
  Future<int> getUsersCountByRole(UserRole role) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.users,
      where: [
        QueryCondition(
          field: 'role',
          value: role.name,
        ),
      ],
    );
    return docs.size;
  }
}
