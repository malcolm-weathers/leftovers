import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/main.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  Auth authHandler = new Auth();

  String currentSelectedValue;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _cEmail = TextEditingController(), _cPassword = TextEditingController(), _cName = TextEditingController(),
        _cAge = TextEditingController();
  String _sex = '';

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && _sex != '') {
      form.save();
      Map<String, dynamic> _data = {
        'name': _cName.text,
        'sex': _sex,
        'age': int.parse(_cAge.text),
        'claimed': []
      };
      authHandler.userRegister(_cEmail.text, _cPassword.text, _data).then((bool success) {
        if (success) {
          _showDialog(context, 'Registration successful', 'You can now log in.', true);
        } else {
          _showDialog(context, 'Registration failed', 'That email may already in use.', false);
        }
      }).catchError((e) {
        _showDialog(context, 'Registration failed', 'That email may already be in use.', false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _cName,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Name',
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Cannot be blank';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextFormField(
                    controller: _cAge,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      hintText: 'Age',
                      labelText: 'Age',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Cannot be blank';
                      }
                      if (int.parse(value) < 13 || int.parse(value) > 110) {
                        return 'Age must be between 13 and 110';
                      }
                      return null;
                    },
                  ),
                  DropdownButton<String>(
                    hint: Text('Gender'),
                    value: currentSelectedValue,
                    items: <String>['M', 'F'].map((String val) {
                      return new DropdownMenuItem<String>(
                        value: val,
                        child: new Text(val),
                      );
                    }).toList(),
                    onChanged: (String newVal) {
                      setState((){
                        currentSelectedValue = newVal;
                        _sex = newVal;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _cEmail,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      hintText: 'Email',
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Cannot be blank';
                      }
                      if (value.indexOf('@') + 1 < value.indexOf('.') && value.indexOf('@') != -1 && value[value.length - 1] != '.' && value[0] != '@') {
                        return null;
                      }
                      return 'Must be a valid email address';
                    },
                  ),
                  TextFormField(
                    controller: _cPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: 'Password',
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Cannot be blank';
                      }
                      if (value.length < 6) {
                        return 'Password must be 6 characters in length or greater';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: 'Confirm password',
                      labelText: 'Confirm password',
                    ),
                    validator: (value) {
                      if (value != _cPassword.text) {
                        return 'Passwords must match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 7.5),
                  RaisedButton(
                    child: Text('REGISTER'),
                    onPressed: _submitForm
                  ),
                ],
              ),
            ]
          )
        )
      )
    );
  }

  void _showDialog(BuildContext context, String title, String body, bool goHome) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                if (goHome) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Main()), (Route route) => false);
                }
              },
            ),
          ],
        );
      }
    );
  }
}
