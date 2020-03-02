import 'package:flutter/material.dart';
import 'package:mmo_foodapp/auth.dart';
import 'package:mmo_foodapp/main.dart';

var currentSelectedValue;

class Config extends StatefulWidget {
  String email, name, sex;
  int age;
  Config(this.email, this.age, this.name, this.sex);
  @override
  ConfigState createState() => ConfigState(email, age, name, sex);
}

class ConfigState extends State<Config> {
  String _email, _name, _sex;
  int _age;
  var dbHandler = Db();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ConfigState(email, age, name, sex) {
    this._email = email;
    this._age = age;
    this._name = name;
    this._sex = sex;
    currentSelectedValue = _sex;
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && _sex != '') {
      form.save();
      dbHandler.setUserData(_email, {'name':_name, 'sex':_sex, 'age':_age});
      _showDialog(context, 'Settings updated', '', true);
    } else {
      print('Validation failed');
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
                  initialValue: _name
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
                  initialValue: _age.toString()
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
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(_email, _name, _sex, _age)), (Route route) => false);

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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(_email, _name, _sex, _age)), (Route route) => false);
                  }
                },
              ),
            ],
          );
        }
    );
  }
}
