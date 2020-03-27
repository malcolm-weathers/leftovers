import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/home.dart';
import 'package:leftovers/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftovers',
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  String _email, _password;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Auth authHandler = new Auth();

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      authHandler.userLogin(_email, _password).then((bool success) {
        if (success) {
          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new Home(_email)));
        } else {
          _showDialog(context, 'Login failed', 'Make sure you have the correct email and password.');
        }
      }).catchError((e) {
        _showDialog(context, 'Login failed', 'Make sure you have the correct email and password.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Leftovers'),
        ),
        body: Center(
            child: new Form(
                key: _formKey,
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15.0),
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                              'assets/icon.png',
                              height: 150,
                              width: 150
                          ),
                          Text(
                              'v0-20200326'
                          ),
                          SizedBox(height:15),
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
                              _password = value;
                              return null;
                            },
                          ),
                          SizedBox(height: 7.5),
                          RaisedButton(
                              onPressed: _submitForm,
                              child: Text(
                                  'LOGIN'
                              )
                          ),
                          SizedBox(height: 15),
                          FlatButton(
                            child: Text('REGISTER'),
                            onPressed: (){
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new Register()));
                            },
                          )
                        ],
                      )
                    ]
                )
            )
        )
    );
  }

  void _showDialog(BuildContext context, String title, String body) {
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
              },
            ),
          ],
        );
      }
    );
  }
}
