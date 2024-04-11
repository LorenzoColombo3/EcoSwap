import '../../model/UserModel.dart';
import '../../util/Result.dart';

abstract class BaseUserAuthDataSource{
  Future<String?> registration({required String email, required String password});
  Future<String?> signInWithGoogle();
  Future<String?> login({required String email, required String password});
  Future<Result?> saveData({required String name, required String lastName,
    required String birthDate, required String phoneNumber});
  Future<String?> readEmail();
  Future<void> saveCredential(String email, String password);
  Future<String?> readPassword();
  void deleteUser();
  Future<void> updatePosition(bool hasPermission);
  Future<bool> signOutFromGoogle();
}