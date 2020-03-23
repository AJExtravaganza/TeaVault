import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  Future signInAnonymously() async {
    final user = await authService.signInAnonymously();
    setState(() {
      _currentUser = user;
    });
  }

  AuthenticationWrapperState(this._childBuilder);

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
      //TODO: Remove this auto-sign-in when proper sign-in and login persistence is implemented
      signInAnonymously();
      return Container();
//      print('Displaying sign-in screen');
//      return SignIn();
    }
  }
}
