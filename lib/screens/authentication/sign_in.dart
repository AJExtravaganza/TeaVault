import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teavault/screens/authentication/authentication_wrapper.dart';
import 'package:teavault/screens/authentication/register.dart';
import 'package:teavault/services/auth.dart';

class SignIn extends StatelessWidget {
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
          child: Column(children: <Widget>[
            SignInForm(),
            RegisterButton()
          ],)),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        TextFormField(
          decoration: InputDecoration(labelText: 'Email'),
          validator: (value) => EmailValidator.validate(value) ? null : "Please enter a valid email address",
          onSaved: (value) => _email = value,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Password'),
          validator: (value) {
            if (value.length < 1) {
              return "Please enter a password";
            }
            return null;
          },
          onSaved: (value) => _password = value,
        ),
        RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text('Sign In'),
            onPressed: () async {
              await signInFormSubmit();
            })
      ]),
    );
  }

  Future signInFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attempting Sign-in...')));
      try {
        await authService.signInWithEmailAndPassword(_email, _password);
        context.findAncestorStateOfType<AuthenticationWrapperState>().refresh();
      } on AuthException catch (err) {
        print('FAILED TO LOG IN: ${err.message}');
      }
    }
  }
}


class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Register New Account'),
      onPressed: () async {
        Navigator.push(context, RegistrationScreen());
      },
    );
  }
}