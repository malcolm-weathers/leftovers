import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/location.dart';
import 'package:leftovers/viewother.dart';

class Search extends StatefulWidget {
  final String _email;
  final Map<String, dynamic> _userData;

  Search(this._email, this._userData);
  @override
  SearchState createState() => SearchState(_email, _userData);
}

class SearchState extends State<Search> {
  String _email;
  Map<String, dynamic> _userData;

  Auth authHandler = new Auth();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _txtLat = TextEditingController(), _txtLon = TextEditingController(), _txtRad = TextEditingController(text: '5.0');

  List<dynamic> _inRange = [];

  SearchState(this._email, this._userData);

  Future<int> _getLD() async {
    for (var _x in _inRange) {
      _x['img0'] = await authHandler.getImage0(_x['id']);
    }

    MyLocation _myLocation = new MyLocation();
    _myLocation.get().then((Map<String, double> _myLoc) {
      _txtLat.text = _myLoc['latitude'].toString();
      _txtLon.text = _myLoc['longitude'].toString();
    });

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLD(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
                title: Text('Search listings')
            ),
            body: Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.my_location),
                                hintText: 'Latitude',
                                labelText: 'Latitude'
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Is blank!';
                              }
                              //_descr = value;
                              return null;
                            },
                            controller: _txtLat,
                          ),
                        ),
                        Flexible(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.my_location),
                                hintText: 'Longitude',
                                labelText: 'Longitude'
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Is blank!';
                              }
                              return null;
                            },
                            controller: _txtLon,
                          ),
                        ),
                        FlatButton(
                            child: Text('CURRENT'),
                            onPressed: () {
                              MyLocation _myLocation = new MyLocation();
                              _myLocation.get().then((Map<String, double> _myLoc) {
                                _txtLat.text = _myLoc['latitude'].toString();
                                _txtLon.text = _myLoc['longitude'].toString();
                              });
                            }
                        ),
                      ],
                    ),
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            icon: Icon(Icons.airport_shuttle),
                            hintText: 'Enter the distance to search from your location',
                            labelText: 'Distance (miles)'
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Cannot be blank!';
                          }
                          return null;
                        },
                        controller: _txtRad,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    RaisedButton(
                        child: Text('SEARCH'),
                        onPressed: _submitForm
                    ),
                    SizedBox(height: 40.0),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _inRange.length,
                        padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                        itemBuilder: (BuildContext ctxt, int index) {
                          return new ListTile(
                              title: Text(
                                _inRange[index]['title'],
                              ),
                              subtitle: Text(
                                  '(${_inRange[index]["distance"]} miles) ${_inRange[index]["descr"]}'
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                              ),
                              onTap: () {
                                Navigator.push(context, new MaterialPageRoute(builder: (context) =>
                                new ViewOther(_email, _userData, _inRange[index]['id'])));
                              },
                              leading: Image.memory(
                                _inRange[index]['img0'],
                                fit: BoxFit.fill,
                              )
                          );
                        }
                    ),
                  ],
                )
              )
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

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      authHandler.listingsGetByLocationNF(double.parse(_txtLat.text), double.parse(_txtLon.text), double.parse(_txtRad.text)).then((List<dynamic> x){
        _inRange = x;
        setState(() {});
      });
    }
  }
}