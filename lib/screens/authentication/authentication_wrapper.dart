import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teavault/screens/authentication/sign_in.dart';
import 'package:teavault/services/auth.dart';

//Serves sign-in screen when not logged in, and listens to changes in authentication state
class AuthenticationWrapper extends StatefulWidget {
  Function _childBuilder;

  AuthenticationWrapper({@required Function builder}) {
    this._childBuilder = builder;
  }

  @override
  State<StatefulWidget> createState() => AuthenticationWrapperState(this._childBuilder);
}

class AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final Function _childBuilder;

  FirebaseUser _currentUser;

  FirebaseUser get currentUser => _currentUser;

  AuthenticationWrapperState(this._childBuilder);

  void refresh() {
    setState(() {
      this._currentUser = authService.lastKnownUser;
    });
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    if (currentUser != null) {
//      print('Got activeUser "${currentUser.uid}" from auth stream');
//    } else {
//      print('No activeUser');
//    }

    if (authService.lastKnownUser != null) {
//      print('Displaying home screen');
      return _childBuilder();
    } else {
//      print('Displaying sign-in screen');
      return SignIn();
    }
  }
}
