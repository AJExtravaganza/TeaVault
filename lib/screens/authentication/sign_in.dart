import 'package:teavault/screens/authentication/authentication_wrapper.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
//  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text('Sign in to TeaVault'),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: RaisedButton(
            child: Text('Sign In Anonymously'),
            onPressed: () async {
              try {
                print('Attempting anonymous sign-in');
                context.findAncestorStateOfType<AuthenticationWrapperState>().signInAnonymously().then((_) {
                  print('Anonymous sign-in successful');
                });
              } catch (err) {
                print(err);
              }
            },
          )),
    );
  }
}
