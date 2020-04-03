import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/config.dart';
import 'package:leftovers/createlisting.dart';
import 'package:leftovers/location.dart';
import 'package:leftovers/main.dart';
import 'package:leftovers/search.dart';
import 'package:leftovers/viewmine.dart';
import 'package:leftovers/viewother.dart';

class Home extends StatefulWidget {
  final String _email;
  Home(this._email);
  @override
  HomeState createState() => HomeState(_email);
}

class HomeState extends State<Home> {
  Auth authHandler = Auth();
  String _email;
  double _lat, _lon;
  Map<String, dynamic> _userData;

  var _listings = [];
  var _claimedData = [];

  HomeState(this._email);

  Future<int> _getData() async {
    MyLocation _myLocation = new MyLocation();
    _myLocation.get().then((Map<String, double> _myLoc) {
      _lat = _myLoc['latitude'];
      _lon = _myLoc['longitude'];
    });
    await authHandler.listingsGetByUser(_email).then((List<Map<String, dynamic>> _results) async {
      _listings = _results;
      for (var _x in _listings) {
        _x['img0'] = await authHandler.getImage0(_x['id']);
      }
    });
    await authHandler.userDataGet(_email).then((Map<String, dynamic> _data) async {
      _userData = _data;
      _claimedData.clear();
      print('claimed has been cleared, now we start adding');
      for (String _x in _userData['claimed']) {
        print('looping for $_x');
        await authHandler.listingGet(_x).then((Map<String, dynamic> _data) async {
          double _olat = _data['location']['latitude'];
          double _olon = _data['location']['longitude'];
          print('variables are $_olat $_olon $_lat $_lon');
          double _dist = (_lat - _olat).abs() * 69.2 + (_lon - _olon).abs() * 69.2;
          _dist = double.parse(_dist.toStringAsFixed(1));
          _data["distance"] = _dist;
          await authHandler.getImage0(_x).then((var _y) {
            _data['img0'] = _y;
            _claimedData.add(_data);
          });
        });
      }
    });
    return 0;
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
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Main()), (Route route) => false);
                                }
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.blue,
                              ),
                              onPressed: (){
                                Navigator.push(context, new MaterialPageRoute(builder: (context) => new Config(_email, _userData)));
                              },
                            ),
                          ],
                        ),
                      ),
                      Text('Welcome, ${_userData["name"]}', textAlign: TextAlign.center,),
                      SizedBox(height: 20.0),
                      RaisedButton(
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new CreateListing(_email)));
                        },
                        //child: Text('CREATE LISTING')
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add),
                            SizedBox(width: 5),
                            Text('DONATE FOOD')
                          ],
                        )
                      ),
                      RaisedButton(
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new Search(_email, _userData)));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.shopping_cart),
                            SizedBox(width: 13),
                            Text('FIND FOOD')
                          ],
                        )
                          //child: Text('FIND FOOD')
                      ),
                      SizedBox(height: 20.0),
                      Text('Your posted listings:'),
                      SizedBox(height: 5.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _listings.length,
                        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                        primary: false,
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
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewMine(_email, _userData, _listings[index]['id'])));
                            },
                            leading: Image.memory(
                              _listings[index]['img0'],
                              fit: BoxFit.fill,
                            )
                          );
                        }
                      ),
                      SizedBox(height: 20.0),
                      Text('Food you have claimed:'),
                      SizedBox(height: 5.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _claimedData.length,
                        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                        primary: false,
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
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewOther(_email, _userData, _userData['claimed'][index])));
                            },
                            leading: Image.memory(
                              _claimedData[index]['img0'],
                              fit: BoxFit.fill,
                            )
                          );
                        }
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