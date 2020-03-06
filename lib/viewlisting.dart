import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmo_foodapp/main.dart';
import 'package:mmo_foodapp/auth.dart';

class ViewListing extends StatefulWidget {
  String _email, _name, _sex, _id;
  int _age;
  var _listing;

  ViewListing(this._email, this._name, this._sex, this._age, this._id);

  @override
  ViewListingState createState() => ViewListingState(_email, _name, _sex, _age, _id);
}

class ViewListingState extends State<ViewListing> {
  String _email, _name, _sex, _id, _times, _timet;
  int _age, _remaining;
  Map<String, dynamic> _listing;
  var dbHandler = new Db();

  ViewListingState(String email, String name, String sex, int age, String id) {
    this._email = email;
    this._name = name;
    this._sex = sex;
    this._age = age;
    this._id = id;

    /*String hours, hourt;
    var ds = DateTime.fromMillisecondsSinceEpoch(listing["time_s"].seconds*1000).toLocal();
    _times = '${ds.year}-${ds.month.toString().padLeft(2, '0')}-${ds.day.toString().padLeft(2, '0')} ${ds.hour.toString().padLeft(2, '0')}:${ds.minute.toString().padLeft(2, '0')}';
    ds = DateTime.fromMillisecondsSinceEpoch(listing["time_t"].seconds*1000).toLocal();
    _timet = '${ds.year}-${ds.month.toString().padLeft(2, '0')}-${ds.day.toString().padLeft(2, '0')} ${ds.hour.toString().padLeft(2, '0')}:${ds.minute.toString().padLeft(2, '0')}';
    */
  }

  Future<int> _getLD() async {
    Map<String, dynamic> map = await dbHandler.getListing(_id);
    print('Got $map');
    _listing = map;
    _remaining = map['quantity'];
    _listing['claimed'].forEach((String key, dynamic value){
      _remaining -= value['no'];
    });

    DateTime ds = DateTime.fromMillisecondsSinceEpoch(map['time_s'].seconds*1000);
    TimeOfDay ts = TimeOfDay(hour: ds.hour, minute: ds.minute);
    TimeOfDay ts2 = ts.replacing(hour: ts.hourOfPeriod);

    String _ampm;
    if (ds.hour < 12) {
      _ampm = 'AM';
    } else {
      _ampm = 'PM';
    }
    _times = '${ds.year}/${ds.month.toString().padLeft(2, '0')}/${ds.day.toString().padLeft(2, '0')} ${ts2.hour}:${ts2.minute.toString().padLeft(2, '0')} $_ampm';

    DateTime dt = DateTime.fromMillisecondsSinceEpoch(map['time_t'].seconds*1000);
    TimeOfDay tt = TimeOfDay(hour: dt.hour, minute: dt.minute);
    TimeOfDay tt2 = ts.replacing(hour: tt.hourOfPeriod);

    if (dt.hour < 12) {
      _ampm = 'AM';
    } else {
      _ampm = 'PM';
    }
    _timet = '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${tt2.hour}:${tt2.minute.toString().padLeft(2, '0')} $_ampm';




    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLD(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          print('Listing is: $_listing');
          return Scaffold(
              appBar: AppBar(
                title: Text(_listing['title']),
              ),
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                      children: <Widget>[
                        Text(
                          _listing['descr'],
                          style: TextStyle(
                              fontSize: 20.0
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          'Total: ${_listing["quantity"]} ($_remaining remaining)',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Limit/person: ${_listing["limit"]}',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          'Latitude: ${_listing["location"]["latitude"]}\nLongitude: ${_listing["location"]["longitude"]}',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.0),
                        Icon(
                          Icons.access_time,
                        ),
                        Text(
                          '$_times\n-\n$_timet',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.0),
                        FlatButton(
                            child: Text(
                                'DELETE LISTING'
                            ),
                            onPressed: () {
                              _showDialog(context, 'Are you sure?', 'Once a listing is deleted, you cannot get it back.');
                            }
                        ),
                        SizedBox(height: 20.0),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: 2,//_listing['claimed'].length,
                            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                            itemBuilder: (BuildContext ctxt, int index) {
                              var _u = _listing['claimed'].keys.elementAt(index);
                              Color _color;
                              bool _vis = true;
                              if (_listing['claimed'][_u]['done'] == false) {
                                _color = Colors.black;
                              } else {
                                _color = Colors.green;
                                _vis = false;
                              }
                              return new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$_u: ${_listing['claimed'][_u]['no'].toString()}",
                                    textScaleFactor: 1.1,
                                    style: TextStyle(
                                      color: _color,
                                    ),
                                  ),
                                  Visibility(
                                    child: IconButton(
                                      icon: Icon(Icons.check_circle),
                                      onPressed: (){
                                        //Map<String, dynamic> map = Map<String, dynamic>.from(_listing);
                                        _listing['claimed'][_u]['done'] = true;
                                        print('${_listing}');
                                        dbHandler.setListingMap(_id, _listing).then((value){
                                          print('All done setting');
                                          Navigator.of(context).pop();
                                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewListing(_email, _name, _sex, _age, _id)));
                                        });
                                      },
                                    ),
                                    visible: _vis,
                                  ),
                                  Visibility(
                                    child: IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: (){

                                      },
                                    ),
                                    visible: _vis,
                                  ),
                                ],
                              );
                            }
                        ),
                      ],
                    )
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

  void _showDialog(BuildContext context, String title, String body) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Delete'),
                onPressed: () {
                  dbHandler.deleteListing(_id);
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(_email, _name, _sex, _age)), (Route route) => false);
                }
              ),
              new RaisedButton(
                child: new Text('Cancel'),
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