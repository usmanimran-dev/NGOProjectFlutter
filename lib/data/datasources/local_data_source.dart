import 'package:hive/hive.dart';
import 'package:demo/data/models/assistance_model.dart';
import 'package:demo/data/models/user_model.dart';

abstract class LocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
  Future<void> cacheOfflineAssistance(AssistanceModel assistance);
  Future<List<AssistanceModel>> getOfflineAssistance();
  Future<void> clearOfflineAssistance();
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<UserModel> userBox;
  final Box<AssistanceModel> assistanceBox;

  LocalDataSourceImpl({required this.userBox, required this.assistanceBox});

  @override
  Future<void> cacheUser(UserModel user) async {
    await userBox.put('last_user', user);
  }

  @override
  Future<UserModel?> getLastUser() async {
    return userBox.get('last_user');
  }

  @override
  Future<void> clearUser() async {
    await userBox.delete('last_user');
  }

  @override
  Future<void> cacheOfflineAssistance(AssistanceModel assistance) async {
    await assistanceBox.add(assistance);
  }

  @override
  Future<List<AssistanceModel>> getOfflineAssistance() async {
    return assistanceBox.values.toList();
  }

  @override
  Future<void> clearOfflineAssistance() async {
    await assistanceBox.clear();
  }
}
