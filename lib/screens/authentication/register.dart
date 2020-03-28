import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teavault/services/auth.dart';

class RegistrationScreen extends MaterialPageRoute {
  RegistrationScreen()
      : super(
            builder: (context) => Scaffold(
                  backgroundColor: Colors.lightGreen[100],
                  appBar: AppBar(
                    backgroundColor: Colors.lightGreen,
                    title: Text('Register a new TeaVault account'),
                  ),
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        flex: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: RegistrationForm(),
                        ),
                      ),
                    ],
                  ),
                ));
}

class RegistrationForm extends StatefulWidget {
  @override
  RegistrationFormState createState() => new RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _confirmPassword;

  bool _emailAlreadyInUse = false;
  bool _passwordConfirmationMismatch = false;

  String passwordValidator(value) {
    if (value.length < 8) {
      return "Please enter a password with 8 or more characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (_emailAlreadyInUse) {
          return "This email address is already in use";
        } else if (!EmailValidator.validate(value)) {
          return "Please enter a valid email address";
        }

        return null;
      },
      onSaved: (value) => _email = value,
    );

    final passwordConfirmField = TextFormField(
      decoration: InputDecoration(labelText: 'Confirm Password'),
      obscureText: true,
      validator: (value) {
        if (passwordValidator(value) != null) {
          return passwordValidator(value);
        } else if (_passwordConfirmationMismatch) {
          return 'Passwords do not match';
        }

        return null;
      },
      onSaved: (value) => _confirmPassword = value,
    );

    if (_emailAlreadyInUse || _passwordConfirmationMismatch) {
      _formKey.currentState.validate();
    }

    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        emailField,
        TextFormField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: passwordValidator,
          onSaved: (value) => _password = value,
        ),
        passwordConfirmField,
        RaisedButton(
            color: Colors.lightGreen,
            textColor: Colors.white,
            child: new Text('Register'),
            onPressed: () async {
              await registrationFormSubmit();
            })
      ]),
    );
  }

  Future registrationFormSubmit() async {
    _emailAlreadyInUse = false;
    _passwordConfirmationMismatch = false;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_password != _confirmPassword) {
        setState(() {
          _passwordConfirmationMismatch = true;
        });
      } else {
        FocusScope.of(context).unfocus(); //Dismiss the keyboard
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attempting to register new user...')));
        try {
          final newUser = await authService.registerWithEmailAndPassword(_email, _password);
          Navigator.pop(context);
        } on PlatformException catch (err) {
          if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
            setState(() {
              _emailAlreadyInUse = true;
            });
          }
        }
      }
    }
  }
}
