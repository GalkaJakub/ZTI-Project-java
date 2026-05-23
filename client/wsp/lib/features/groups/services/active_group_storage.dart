import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ActiveGroupStorage {
  ActiveGroupStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _activeGroupIdKey = 'groups.active_group_id';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveActiveGroupId(int groupId) {
    return _secureStorage.write(
      key: _activeGroupIdKey,
      value: groupId.toString(),
    );
  }

  Future<int?> readActiveGroupId() async {
    final value = await _secureStorage.read(key: _activeGroupIdKey);
    return int.tryParse(value ?? '');
  }

  Future<void> clear() {
    return _secureStorage.delete(key: _activeGroupIdKey);
  }
}
