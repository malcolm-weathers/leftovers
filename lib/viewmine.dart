import 'package:flutter/material.dart';

import 'package:leftovers/auth.dart';

class ViewMine extends StatefulWidget {
  final String _email, _id;
  final Map<String, dynamic> _userData;

  ViewMine(this._email, this._userData, this._id);

  @override
  ViewMineState createState() => ViewMineState(_email, _userData, _id);
}

class ViewMineState extends State<ViewMine> {
  String _email, _id, _timeS, _timeT;
  int _remaining;
  Map<String, dynamic> _userData, _listingData;

  Auth authHandler = new Auth();

  ViewMineState(this._email, this._userData, this._id);

  Future<int> _getLD() async {
    await authHandler.listingGet(_id).then((Map<String, dynamic> _data) {
      _listingData = _data;
    });

    _remaining = _listingData['quantity'];
    _listingData['claimed'].forEach((String key, dynamic value){
      if (_listingData['claimed'][key]['status'] != 'cancelled')
        _remaining -= value['no'];
    });

    await authHandler.getImage0(_id).then((var _y) {
      _listingData['img0'] = _y;
    });

    DateTime ds = DateTime.fromMillisecondsSinceEpoch(_listingData['time_s'].round()*1000).toLocal();
    TimeOfDay ts = TimeOfDay(hour: ds.hour, minute: ds.minute);
    TimeOfDay ts2 = ts.replacing(hour: ts.hourOfPeriod);

    String _ampm;
    if (ds.hour < 12) {
      _ampm = 'AM';
    } else {
      _ampm = 'PM';
    }
    _timeS = '${ds.year}/${ds.month.toString().padLeft(2, '0')}/${ds.day.toString().padLeft(2, '0')} ${ts2.hour}:${ts2.minute.toString().padLeft(2, '0')} $_ampm';

    DateTime dt = DateTime.fromMillisecondsSinceEpoch(_listingData['time_t'].round()*1000).toLocal();
    TimeOfDay tt = TimeOfDay(hour: dt.hour, minute: dt.minute);
    TimeOfDay tt2 = ts.replacing(hour: tt.hourOfPeriod);

    if (dt.hour < 12) {
      _ampm = 'AM';
    } else {
      _ampm = 'PM';
    }
    _timeT = '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${tt2.hour}:${tt2.minute.toString().padLeft(2, '0')} $_ampm';

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: _getLD(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('Listing is: $_listingData');
            return Scaffold(
              appBar: AppBar(
                title: Text('Manage Your Listing'),
              ),
              body: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                children: <Widget>[
                  SizedBox(height: 10),
                  Image.memory(
                    _listingData['img0'],
                    fit: BoxFit.fitHeight,
                    height: 200,
                  ),
                  Text(
                    _listingData['title'],
                    style: TextStyle(
                        fontSize: 20.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    _listingData['descr'],
                    style: TextStyle(
                        fontSize: 14.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 22.0),
                  Text(
                    'Total: ${_listingData["quantity"]} ($_remaining remaining)',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Limit/person: ${_listingData["limit"]}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Latitude: ${_listingData["location"]["latitude"]}\nLongitude: ${_listingData["location"]["longitude"]}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.0),
                  Icon(
                    Icons.access_time,
                  ),
                  Text(
                    '$_timeS\n-\n$_timeT',
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
                    itemCount: _listingData['claimed'].length,
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                    itemBuilder: (BuildContext ctxt, int index) {
                      var _u = _listingData['claimed'].keys.elementAt(index);
                      Color _color;
                      bool _vis0 = false, _vis1 = false;
                      if (_listingData['claimed'][_u]['status'] == 'reserved') {
                        _color = Colors.black;
                        _vis0 = true;
                      } else if (_listingData['claimed'][_u]['status'] == 'received') {
                        _color = Colors.green;
                        _vis1 = true;
                      } else if (_listingData['claimed'][_u]['status'] == 'cancelled') {
                        _color = Colors.red;
                        _vis1 = true;
                      }
                      return new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "$_u: ${_listingData['claimed'][_u]['no'].toString()}",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: _color,
                            ),
                          ),
                          Visibility(
                              child: IconButton(
                                icon: Icon(Icons.check_circle),
                                onPressed: (){
                                  _listingData['claimed'][_u]['status'] = 'received';
                                  authHandler.listingSet(_id, _listingData).then((value){
                                    Navigator.of(context).pop();
                                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewMine(_email, _userData, _id)));
                                  });
                                },
                              ),
                              visible: _vis0
                          ),
                          Visibility(
                              child: IconButton(
                                icon: Icon(Icons.cancel),
                                onPressed: (){
                                  _listingData['claimed'][_u]['status'] = 'cancelled';
                                  authHandler.listingSet(_id, _listingData).then((value){
                                    Navigator.of(context).pop();
                                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewMine(_email, _userData, _id)));
                                  });
                                },
                              ),
                              visible: _vis0
                          ),
                          Visibility(
                            child: IconButton(
                              icon: Icon(Icons.undo),
                              onPressed: (){
                                _listingData['claimed'][_u]['status'] = 'reserved';
                                authHandler.listingSet(_id, _listingData).then((value){
                                  Navigator.of(context).pop();
                                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewMine(_email, _userData, _id)));
                                });
                              },
                            ),
                            visible: _vis1
                          ),
                        ],
                      );
                    }
                  ),
                ],
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
                    authHandler.listingDelete(_id);
                    authHandler.imageDelete(_id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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