import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mmo_foodapp/auth.dart';
import 'package:mmo_foodapp/config.dart';
import 'package:mmo_foodapp/makelisting.dart';
import 'package:mmo_foodapp/register.dart';
import 'package:mmo_foodapp/viewlisting.dart';
import 'package:mmo_foodapp/search.dart';
import 'package:mmo_foodapp/viewforeign.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftovers',
      home: Root(),
    );
  }
}

class Root extends StatefulWidget {
  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  String _email, _name, _sex, _password;
  int _age;

  var authHandler = new Auth();
  var dbHandler = new Db();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      authHandler.handleSignIn(_email, _password).then((FirebaseUser user) {
        dbHandler.getValues(_email).then((Map<String,dynamic> map) {
          _age = map['age'];
          _name = map['name'];
          _sex = map['sex'];
          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new Home(_email, _name, _sex, _age)));
        });
      }).catchError((e){
        showAlert(context, 'Login failed', 'Make sure you have the correct email and password.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leftovers'),
      ),
      //body: _buildLogin(),
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
                      'icon.png',
                      height: 150,
                      width: 150
                  ),
                  Text(
                      'v0-20200311'
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
}

class Home extends StatefulWidget {
  final String _email, _name, _sex;
  final int _age;

  Home(this._email, this._name, this._sex, this._age);

  @override
  HomeState createState() => HomeState(_email, _name, _sex, _age);
}

class HomeState extends State<Home> {
  var dbHandler = Db();
  String _email, _name, _sex;
  int _age;

  var _listings = [];
  var _claimed = [];
  var _claimedData = [];

  HomeState(String email, String name, String sex, int age) {
    print('Creating homestate!');
    this._email = email;
    this._name = name;
    this._sex = sex;
    this._age = age;
  }

  Future<int> _getData() async {
    await dbHandler.getListings(_email).then((List<dynamic> list) async {
      _listings = list;
      await dbHandler.getValues(_email).then((Map<String, dynamic> userData) async {
        _claimed = userData['claimed'];
        await dbHandler.getDataForClaimed(_claimed).then((List<dynamic> list) {
          _claimedData = list;
          return 0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Leftovers'),
              ),
              body: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(15.0),//Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                              child: Text(
                                  'LOGOUT'
                              ),
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Root()), (Route route) => false);
                              }
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.blue,
                            ),
                            onPressed: (){
                              print('Config!');
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new Config(_email, _age, _name, _sex)));
                            },
                          ),
                        ],
                      ),

                    ),
                    SizedBox(height: 20.0),
                    Text('Welcome, $_name'),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new MakeListing(_email, _name, _sex, _age)));
                        },
                        child: Text('CREATE LISTING')
                    ),
                    RaisedButton(
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new Search(_email, _name, _sex, _age, _claimed)));
                        },
                        child: Text('FIND FOOD')
                    ),
                    SizedBox(height: 20.0),
                    Text('Your posted listings:'),
                    Container(
                      //decoration: BoxDecoration(border: Border.all(width: 2.0, color: Colors.blue)),
                      constraints: BoxConstraints(maxHeight: 200),
                      //height: 200,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _listings.length,
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new ListTile(
                                title: Text(
                                  _listings[index]['title'],
                                ),
                                subtitle: Text(
                                  _listings[index]['descr'],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                ),
                                onTap: () {
                                  print('${_listings[index].data}');
                                  Navigator.push(context, new MaterialPageRoute(builder: (context) =>
                                  new ViewListing(_email, _name, _sex, _age, _listings[index].documentID)));
                                }
                            );
                          }
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text('Food you have claimed:'),
                    Container(
                      //decoration: BoxDecoration(border: Border.all(width: 2.0, color: Colors.blue)),
                      constraints: BoxConstraints(maxHeight: 200),
                      //height: 200,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _claimedData.length,
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new ListTile(
                                title: Text(
                                  _claimedData[index]['title'],
                                ),
                                subtitle: Text(
                                    '(${_claimedData[index]["distance"]} miles) ${_claimedData[index]["descr"]}'
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                ),
                                onTap: () {
                                  Navigator.push(context, new MaterialPageRoute(builder: (context) =>
                                  new ViewForeign(_email, _name, _sex, _age, _claimed, _claimed[index], _claimedData[index])));
                                }
                            );
                          }
                      ),
                    ),
                  ]
              )
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                title: Text('Leftovers'),
              ),
              body: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  )
              )
          );
        }
      }
    );
  }
}

void showAlert(BuildContext context, String title, String body) {
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