import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:leftovers/auth.dart';

class ViewOther extends StatefulWidget {
  final String _email, _id;
  final Map<String, dynamic> _userData;
  ViewOther(this._email, this._userData, this._id);
  @override
  ViewOtherState createState() => ViewOtherState(_email, _userData, _id);
}

class ViewOtherState extends State<ViewOther> {
  String _email, _id;
  Map<String, dynamic> _userData, _listingData;
  int _remaining;
  Auth authHandler = new Auth();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _txtClaim = new TextEditingController();
  List<Uint8List> _images = [];

  DateTime _start, _finish;
  String _startS, _finishS;

  ViewOtherState(this._email, this._userData, this._id);

  Future<int> _getLD() async {
    await authHandler.listingGet(_id).then((Map<String, dynamic> _data) async {
      _listingData = _data;
      _remaining = _listingData['quantity'];
      _listingData['claimed'].forEach((String key, dynamic value){
        if (_listingData['claimed'][key]['status'] != 'cancelled')
          _remaining -= value['no'];
      });

      if (_listingData['claimed'].containsKey(_email)) {
        _txtClaim.text = _listingData['claimed'][_email]['no'].toString();
      } else {
        _txtClaim.text = '0';
      }

      _start = DateTime.fromMillisecondsSinceEpoch(_listingData['time_s'].round()*1000);
      _finish = DateTime.fromMillisecondsSinceEpoch(_listingData['time_t'].round()*1000);
      _setTimeStrings();

      _images.clear();
      await authHandler.getImage0(_id).then((Uint8List _img) {
        _images.add(_img);
        return 0;
      });
    });
    return 0;
  }

  void _setTimeStrings() {
    String _hourS, _hourT, _amS, _amT;

    if (_start.hour == 0) {
      _hourS = '12';
      _amS = 'AM';
    } else if (_start.hour >= 12) {
      _amS = 'PM';
      if (_start.hour > 12) {
        _hourS = (_start.hour - 12).toString();
      } else {
        _hourS = _start.hour.toString();
      }
    } else {
      _hourS = _start.hour.toString();
      _amS = 'AM';
    }

    if (_finish.hour == 0) {
      _hourT = '12';
      _amT = 'AM';
    } else if (_finish.hour >= 12) {
      _amT = 'PM';
      if (_finish.hour > 12) {
        _hourT = (_finish.hour - 12).toString();
      } else {
        _hourT = _finish.hour.toString();
      }
    } else {
      _hourT = _finish.hour.toString();
      _amT = 'AM';
    }
    _startS = '${_start.year}/${_start.month.toString().padLeft(2, "0")}/${_start.day.toString().padLeft(2, "0")} $_hourS:${_start.minute.toString().padLeft(2, "0")} $_amS';
    _finishS = '${_finish.year}/${_finish.month.toString().padLeft(2, "0")}/${_finish.day.toString().padLeft(2, "0")} $_hourT:${_finish.minute.toString().padLeft(2, "0")} $_amT';
  }

    @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLD(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Leftovers'),
            ),
            body: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
              children: <Widget>[
                Image.memory(
                  _images[0],
                  height: 200,
                ),
                SizedBox(height: 20.0),
                Text(
                  _listingData['title'],
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height:10.0),
                Text(
                  _listingData['descr'],
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.0),
                Text(
                  'Location:\n${_listingData["location"]["latitude"].toStringAsFixed(2)}\u00B0N, ${_listingData["location"]["longitude"].toStringAsFixed(2)}\u00B0W',
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  child: Text('COPY TO CLIPBOARD'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '${_listingData["location"]["latitude"]}, ${_listingData["location"]["longitude"]}'));
                  }
                ),
                Text(
                    'Copy the coordinates and paste into a maps app (Google Maps, Apple Maps, etc).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.0,
                    )
                ),
                SizedBox(height: 15.0),
                Text(
                  'Pickup time:\n$_startS\nto\n$_finishS',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.0),
                Text(
                  '$_remaining out of ${_listingData["quantity"]} remaining',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  )
                ),
                _listingData['limit'] == 0 ? Text('Limit/person: None!',textAlign: TextAlign.center) : Text('Limit/person: ${_listingData["limit"]}',textAlign:TextAlign.center),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.fastfood),
                            hintText: 'New amount',
                            labelText: 'Amount'
                          ),
                          keyboardType: TextInputType.number,
                          controller: _txtClaim,
                          validator: (value) {
                            if (_listingData['email'] == _email) {
                              return 'Can\'t claim your own listing';
                            }
                            if (value.isEmpty) {
                              return 'Cannot be blank';
                            }
                            if (int.parse(value) < 0) {
                              return 'Cannot be negative';
                            }
                            if (int.parse(value) > _remaining) {
                              return 'Not enough left';
                            }
                            if (int.parse(value) > _listingData['limit'] && _listingData['limit'] != 0) {
                              return 'Limit is ${_listingData["limit"]}';
                            }
                            return null;
                          }
                        )
                      ),
                      SizedBox(width: 10.0),
                      RaisedButton(
                          child: Text('CLAIM'),
                          onPressed: _submitForm
                      ),
                      SizedBox(width: 10.0),
                      RaisedButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          int _amt = int.parse(_txtClaim.text);
                          if (_amt != 0) {
                            _showHome(context, 'Reservation deletion', 'If you confirm, your reservation will be deleted.');

                            /*_listingData['claimed'].remove(_email);
                            _userData['claimed'].remove(_id);
                            authHandler.userDataSet(_email, _userData);
                            authHandler.listingSet(_id, _listingData).then((value) {

                            });
                          } else {
                            Navigator.of(context).pop();*/
                          } else {
                            Navigator.of(context).pop();
                          }
                        }
                      )
                    ],
                  )
                )
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

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      int _amt = int.parse(_txtClaim.text);

      if (_listingData['claimed'].containsKey(_email)) {
        if (_listingData['claimed'][_email]['status'] == 'cancelled') {
          _showDialog(context, 'Error', 'Your reservation was cancelled by the listing owner. You cannot reserve food.');
          return;
        } else if (_listingData['claimed'][_email]['status'] == 'received') {
          _showDialog(context, 'Error', 'Your reservation has been marked as received by the listing owner. You may not claim any more food unless they undo this.');
          return;
        }
      }

      if (_amt == 0 && _listingData['claimed'].containsKey(_email)) {
        _showHome(context, 'Reservation deletion', 'If you confirm, your reservation will be deleted.');
        /*_listingData['claimed'].remove(_email);
        _userData['claimed'].remove(_id);
        authHandler.userDataSet(_email, _userData);
        authHandler.listingSet(_id, _listingData).then((value){
          _showHome(context, 'Reservation deletion', 'If you confirm, your reservation will be deleted.');
        });*/
      } else if (_amt != 0 && _listingData['claimed'].containsKey(_email)) {
        _listingData['claimed'][_email] = {
          'no': _amt,
          'status': 'reserved'
        };

        if (!_userData['claimed'].contains(_id)) {
          _userData['claimed'].add(_id);
        }
        authHandler.userDataSet(_email, _userData);
        authHandler.listingSet(_id, _listingData).then((value){
          _showDialog(context, 'Reservation updated', 'The amount of food you have claimed has been updated to $_amt servings.');
        });
      } else if (_amt != 0) {
        _listingData['claimed'][_email] = {
          'no': _amt,
          'status': 'reserved'
        };

        if (!_userData['claimed'].contains(_id)) {
          _userData['claimed'].add(_id);
        }
        authHandler.userDataSet(_email, _userData);
        authHandler.listingSet(_id, _listingData).then((value){
          _showDialog(context, 'Reservation created', 'You have claimed $_amt servings.');
        });
      }
    }
  }

  void _showDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new RaisedButton(
              child: new Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                //Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewForeign(_email, _name, _sex, _age, _claimed, _id, _listing)));
              },
            ),
          ],
        );
      }
    );
  }

  void _showHome(BuildContext context, String title, String body) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: <Widget>[
              new RaisedButton(
                child: new Text('Confirm'),
                onPressed: () {
                  _listingData['claimed'].remove(_email);
                  _userData['claimed'].remove(_id);
                  authHandler.userDataSet(_email, _userData);
                  authHandler.listingSet(_id, _listingData).then((value) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    //Navigator.push(context, new MaterialPageRoute(builder: (context) => new Home(_email)));
                  });
                },
              ),
              new RaisedButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              )
            ],
          );
        }
    );
  }
}