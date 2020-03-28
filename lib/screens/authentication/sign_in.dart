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
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0.0,
        title: Text('Sign in to TeaVault'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
            child: Container(),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: SignInForm(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.lightGreen[100],
          child: Container(padding: EdgeInsets.symmetric(horizontal: 100.0), child: RegisterButton())),
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
  bool _wrongPasswordEntered = false;

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) => EmailValidator.validate(value) ? null : "Please enter a valid email address",
      onSaved: (value) => _email = value,
    );

    final passwordField = TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (_wrongPasswordEntered) {
          return "Email or password incorrect";
        }
        if (value.length < 1) {
          return "Please enter a password";
        }
        return null;
      },
      onSaved: (value) => _password = value,
    );

    if (_wrongPasswordEntered) {
      _formKey.currentState.validate();
    }

    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        emailField,
        passwordField,
        RaisedButton(
            color: Colors.lightGreen,
            textColor: Colors.white,
            child: new Text('Sign In'),
            onPressed: () async {
              await signInFormSubmit();
            })
      ]),
    );
  }

  Future signInFormSubmit() async {
    _wrongPasswordEntered = false;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attempting Sign-in...')));
      try {
        await authService.signInWithEmailAndPassword(_email, _password);
        context.findAncestorStateOfType<AuthenticationWrapperState>().refresh();
      } on AuthException catch (err) {
        setState(() {
          _wrongPasswordEntered = true;
        });
      }
    }
  }
}

class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.lightGreen,
      textColor: Colors.white,
      child: Text('Register New Account'),
      onPressed: () async {
        Navigator.push(context, RegistrationScreen());
      },
    );
  }
}
