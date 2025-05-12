import 'package:my_flutter_framework/database/hive_repository.dart';
import 'package:my_flutter_framework/models/user.dart';
import 'package:my_flutter_framework/shared/utils/jwt_utils.dart';

class UserRepository {
  static const String _boxName = 'userBox';
  static const String _userKey = 'user';

  /// 儲存登入後的 user 資料（建議傳入 Map 或 model.toMap()）
  static Future<void> saveUser(User user) async {
    await HiveRepository.openBox(_boxName);
    await HiveRepository.putModel(
      _boxName,
      _userKey,
      () => user.toJson(),
    );
  }

  /// 取得目前登入的 user 資料
  static Future<User?> getUser() async {
    await HiveRepository.openBox(_boxName);
    final user = HiveRepository.getAsModel<User>(
      _boxName,
      _userKey,
      fromMap: (data) => User.fromJson(data),
    );
    return user;
  }

  /// 清除 user 資料（登出時可用）
  static Future<void> clearUser() async {
    await HiveRepository.openBox(_boxName);
    await HiveRepository.delete(_boxName, _userKey);
  }

  /// 驗證目前登入的 user token 是否有效（JWT 過期時間解析）
  static Future<bool> isTokenValid() async{
    final user = await getUser();
    if (user == null) return false;
    final token = user.token;
    if (token.isEmpty) return false;
    final exp = JwtUtils.getJwtExp(token);
    if (exp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp > now;
  }
}
