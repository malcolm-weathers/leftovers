import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mmo_foodapp/auth.dart';
import 'package:mmo_foodapp/main.dart';

var currentSelectedValue;

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  var authHandler = new Auth();
  var dbHandler = new Db();
  String _email = '', _password = '', _name = '', _sex = '';
  int _age = 0;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && _sex != '') {
      form.save();
      authHandler.handleRegister(_email, _password).then((FirebaseUser user) {
        print('Registered $_email');
        dbHandler.setUserData(_email, {'name':_name, 'sex':_sex, 'age':_age});
        _showDialog(context, 'Registration successful', 'You can now log in.', true);
      }).catchError((e){
        _showDialog(context, 'Registration failed', 'This email is probably already in use.', false);
      });
    } else {
      print('Validation failed');
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
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Name',
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Cannot be blank';
                      }
                      _name = value;
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextFormField(
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
                        return 'Pick a real age';
                      }
                      _age = int.parse(value);
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
                        _email = value;
                        return null;
                      }
                      return 'Must be a valid email address';
                    },
                  ),
                  TextFormField(
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
                      _password = value;
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
                      if (value != _password) {
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Root()), (Route route) => false);
                  }
                },
              ),
            ],
          );
        }
    );
  }
}
