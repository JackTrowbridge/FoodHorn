import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:foodhorn/src/core/models/user.dart';

class DeviceProvider extends ChangeNotifier{

  User? currentUser;

  void setCurrentUser(User user){
    currentUser = user;
    notifyListeners();
  }

  bool isUserLoggedIn(){
    return currentUser != null;
  }

}