import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/home.dart';

class Config extends StatefulWidget {
  final String _email;
  final Map<String, dynamic> _userData;

  Config(this._email, this._userData);
  @override
  ConfigState createState() => ConfigState(_email, _userData);
}

class ConfigState extends State<Config> {
  String _email;
  Map<String, dynamic> _userData;

  Auth authHandler = Auth();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _cName = TextEditingController(), _cAge = TextEditingController();
  String currentSelectedValue = '';

  ConfigState(email, userData) {
   this._email = email;
   this._userData = userData;
   currentSelectedValue = _userData['sex'];
   _cName.text = _userData['name'];
   _cAge.text = _userData['age'].toString();
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && currentSelectedValue != '') {
      form.save();
      Map<String, dynamic> _newData = {
        'name': _cName.text,
        'age': int.parse(_cAge.text),
        'sex': currentSelectedValue,
        'claimed': _userData['claimed']
      };
      authHandler.userDataSet(_email.replaceAll('.', ','), _newData).then((int result) {
        Navigator.of(context).pop();
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Settings')
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          Form(
            key: _formKey,
            child: new Column(
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
                    });
                  },
                ),
                SizedBox(height: 7.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                        child: Text('UPDATE'),
                        onPressed: _submitForm
                    ),
                    SizedBox(width: 50),
                    RaisedButton(
                      child: Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }
                    ),
                  ]
                )
              ]
            )
          )
        ]
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(_email)), (Route route) => false);
                  }
                },
              ),
            ],
          );
        }
    );
  }
}
