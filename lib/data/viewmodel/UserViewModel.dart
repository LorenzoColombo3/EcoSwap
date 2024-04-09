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

  Future<String?> saveData({required String name, required String lastName,
                            required String birthDate, required String phoneNumber, required String position}){
    return _userRepository.saveData(name: name, lastName: lastName, birthDate: birthDate, phoneNumber: phoneNumber, position: position);
  }

  void deleteUser(){_userRepository.deleteUser();}

  Future<void> updatePosition(bool hasPermission)async { _userRepository.updatePosition(hasPermission);}

  Future<bool> signOutFromGoogle() async {
    return _userRepository.signOutFromGoogle();
  }
}