import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:teavault/services/auth.dart';

class RegistrationScreen extends MaterialPageRoute {
  RegistrationScreen(): super(builder:(context) => Scaffold(
    appBar: AppBar(title: Text('Register a new TeaVault account'),),
    body: RegistrationForm(),
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
                if (value.length < 8) {
                  return "Please enter a password with 8 or more characters";
                }
                return null;
              },
              onSaved: (value) => _password = value,
            ),
            RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('Register'),
                onPressed: () async {
                  await registrationFormSubmit();
                })
          ]),
    );
  }

  Future registrationFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Registering new user...')));
      final newUser = await authService.registerWithEmailAndPassword(_email, _password);
      Navigator.pop(context);
    }
  }
}
