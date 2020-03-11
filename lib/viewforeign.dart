import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmo_foodapp/auth.dart';

class ViewForeign extends StatefulWidget {
  final String _email, _name, _sex, _id;
  final int _age;
  final dynamic _data;

  ViewForeign(this._email, this._name, this._sex, this._age, this._id, this._data);

  @override
  ViewForeignState createState() => ViewForeignState(_email, _name, _sex, _age, _id, _data);
}

class ViewForeignState extends State<ViewForeign> {
  String _email, _name, _sex, _id, _timeS, _timeT;
  int _age, _remaining;
  var _data;
  Map<String, dynamic> _listing;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var dbHandler = new Db();

  var _txtClaim = new TextEditingController();

  ViewForeignState(String email, String name, String sex, int age, String id, dynamic data) {
    this._email = email;
    this._name = name;
    this._sex = sex;
    this._age = age;
    this._id = id;
    this._data = data;
  }

  Future<int> _getLD() async {
    print('Got data $_data');
    _listing = _data;
    if (_listing.containsKey('id')) {
      _listing.remove('id');
    }
    _remaining = _listing['quantity'];
    _listing['claimed'].forEach((String key, dynamic value){
      if (_listing['claimed'][key]['status'] != 'cancelled')
        _remaining -= value['no'];
    });

    if (_listing['claimed'].containsKey(_email)) {
      _txtClaim.text = _listing['claimed'][_email]['no'].toString();
    } else {
      _txtClaim.text = '0';
    }

    DateTime ds = DateTime.fromMillisecondsSinceEpoch(_listing['time_s'].round()*1000).toLocal();
    TimeOfDay ts = TimeOfDay(hour: ds.hour, minute: ds.minute);
    TimeOfDay ts2 = ts.replacing(hour: ts.hourOfPeriod);

    String _ampm;
    if (ds.hour < 12) {
      _ampm = 'AM';
    } else {
      _ampm = 'PM';
    }
    _timeS = '${ds.year}/${ds.month.toString().padLeft(2, '0')}/${ds.day.toString().padLeft(2, '0')} ${ts2.hour}:${ts2.minute.toString().padLeft(2, '0')} $_ampm';

    DateTime dt = DateTime.fromMillisecondsSinceEpoch(_listing['time_t'].round()*1000).toLocal();
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
                            '$_timeS\n-\n$_timeT',
                            textAlign: TextAlign.center,
                          ),
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
                                        hintText: 'Update, or 0 to cancel',
                                        labelText: 'Amount currently claimed'
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _txtClaim,
                                    validator: (value) {
                                      if (_listing['email'] == _email) {
                                        return 'Can\'t claim your own listing';
                                      }
                                      if (value.isEmpty) {
                                        return 'Cannot be blank';
                                      }
                                      if (int.parse(value) < 0) {
                                        return 'Cannot be negative';
                                      }
                                      if (int.parse(value) > _listing['limit']) {
                                        return 'Can\'t be higher than the limit';
                                      }
                                      if (int.parse(value) > _remaining) {
                                        return 'Can\'t be higher than the amount left';
                                      }
                                      return null;
                                    }
                                  )
                                ),
                                SizedBox(width: 10.0),
                                RaisedButton(
                                  child: Text('CLAIM'),
                                  onPressed: _submitForm
                                )
                              ],
                            )
                          )
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

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      int _amt = int.parse(_txtClaim.text);

      if (_listing['claimed'].containsKey(_email)) {
        if (_listing['claimed'][_email]['status'] == 'cancelled') {
          _showDialog(context, 'Error', 'Your reservation was cancelled by the listing owner. You cannot reserve food.');
        } else if (_listing['claimed'][_email]['status'] == 'received') {
          _showDialog(context, 'Error', 'Your reservation has been marked as received by the listing owner. You may not claim any more food unless they undo this');
        }
      }

      if (_amt == 0 && _listing['claimed'].containsKey(_email)) {
        _listing['claimed'].remove(_email);
        dbHandler.setListingMap(_id, _listing).then((value){
          _showDialog(context, 'Reservation deleted', 'You are no longer reserving any food from this listing.');
        });
      } else if (_amt != 0 && !_listing['claimed'].containsKey(_email)) {
        _listing['claimed'][_email] = {
          'no': _amt,
          'status': 'reserved'
        };
        dbHandler.setListingMap(_id, _listing).then((value){
          _showDialog(context, 'Reservation updated', 'The amount of food you have claimed has been updated to $_amt servings.');
        });
      } else if (_amt != 0) {
        _listing['claimed'][_email] = {
          'no': _amt,
          'status': 'reserved'
        };
        dbHandler.setListingMap(_id, _listing).then((value){
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
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new ViewForeign(_email, _name, _sex, _age, _id, _listing)));
                },
              ),
            ],
          );
        }
    );
  }
}