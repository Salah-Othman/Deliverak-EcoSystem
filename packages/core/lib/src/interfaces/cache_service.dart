abstract class ICacheService {
  Future<void> init();

  Future<void> put<T>(String boxName, String key, T value);

  T? get<T>(String boxName, String key);

  Future<void> delete(String boxName, String key);

  Future<void> clearBox(String boxName);

  Future<void> clearAll();

  bool containsKey(String boxName, String key);
}
