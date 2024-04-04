import 'package:eco_swap/data/repository/IUserRepository.dart';

class UserViewModel{
  final IUserRepository _userRepository;

  UserViewModel(IUserRepository userRepository)
    : _userRepository = userRepository;

  Future<String?> registration({required String email, required String password}) {
    return _userRepository.registration(email: email, password: password);
  }

  Future<String?> login({required String email, required String password}) {
    return _userRepository.login(email: email, password: password);
  }
}