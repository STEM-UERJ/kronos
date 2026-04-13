import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageWrapper {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<bool> containsKey({required String key});

  Future<void> delete({required String key});

  Future<void> deleteAll();
}

final class FlutterSecureStorageWrapper implements SecureStorageWrapper {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageWrapper({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<bool> containsKey({required String key}) {
    return _storage.containsKey(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }
}
