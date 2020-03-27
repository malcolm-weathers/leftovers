import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import 'package:leftovers/auth.dart';
import 'package:leftovers/home.dart';
import 'package:leftovers/location.dart';

class CreateListing extends StatefulWidget {
  final String _email;

  CreateListing(this._email);
  @override
  CreateListingState createState() => CreateListingState(_email);
}

class CreateListingState extends State<CreateListing> {
  String _email;
  String _title, _descr;
  int _quantity, _limit;
  double _lat, _lon;

  var _imgs = [];

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var txtLat = TextEditingController();
  var txtLon = TextEditingController();
  Auth authHandler = new Auth();

  String _timeS, _timeT;

  DateTime _selectedDateS = DateTime.now();
  DateTime _selectedDateT = DateTime.now();
  TimeOfDay _selectedTimeS = TimeOfDay.now();
  TimeOfDay _selectedTimeT = TimeOfDay.now();

  CreateListingState(String email) {
    _email = email;

    TimeOfDay tt = _selectedTimeS.replacing(hour: _selectedTimeS.hourOfPeriod);

    if (_selectedTimeS.hour < 12) {
      _timeS = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
    } else {
      _timeS = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
    }
    tt = _selectedTimeT.replacing(hour: _selectedTimeT.hourOfPeriod);
    if (_selectedTimeT.hour < 12) {
      _timeT = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
    } else {
      _timeT = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
    }
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && _timeS != null && _timeT != null) {
      form.save();

      DateTime dss = DateTime.utc(_selectedDateS.year, _selectedDateS.month, _selectedDateS.day,
          _selectedTimeS.hour, _selectedTimeS.minute).toLocal().add(Duration(hours:5));
      DateTime dst = DateTime.utc(_selectedDateT.year, _selectedDateT.month, _selectedDateT.day,
          _selectedTimeT.hour, _selectedTimeT.minute).toLocal().add(Duration(hours:5));

      Map<String, dynamic> newListing = {
        'email': _email,
        'title': _title,
        'descr': _descr,
        'quantity': _quantity,
        'limit': _limit,
        'location': {
          'latitude': _lat,
          'longitude': _lon
        },
        'time_s': dss.millisecondsSinceEpoch / 1000,
        'time_t': dst.millisecondsSinceEpoch / 1000,
        'claimed': {},
      };

      authHandler.listingSet(null, newListing).then((value) {
        _showDialog(context, 'Listing created', '');
      });
    } else {
      print('Listing could not be created');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateS,
        firstDate: DateTime.now().subtract(Duration(days: 1)),// DateTime(2015, 8),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if (picked != null && picked != _selectedDateS)
      setState(() {
        _selectedDateS = picked;
      });
  }

  Future<void> _selectDateT(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateT,
        firstDate: DateTime.now().subtract(Duration(days: 1)),// DateTime(2015, 8),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if (picked != null && picked != _selectedDateT)
      setState(() {
        _selectedDateT = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeS,
    );
    if (picked != null && picked != _selectedTimeS)
      setState(() {
        _selectedTimeS = picked;
        TimeOfDay tt = _selectedTimeS.replacing(hour: _selectedTimeS.hourOfPeriod);
        if (_selectedTimeS.hour < 12) {
          _timeS = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
        } else {
          _timeS = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
        }
      });
  }

  Future<void> _selectTimeT(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeT,
    );
    if (picked != null && picked != _selectedTimeT)
      setState(() {
        _selectedTimeT = picked;
        TimeOfDay tt = _selectedTimeT.replacing(hour: _selectedTimeT.hourOfPeriod);
        if (_selectedTimeT.hour < 12) {
          _timeT = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
        } else {
          _timeT = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
        }
      });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imgs.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create listing'),
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
                                icon: Icon(Icons.fastfood),
                                hintText: 'Pick a short but descriptive title',
                                labelText: 'Listing title'
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Cannot be blank';
                              }
                              _title = value;
                              return null;
                            }
                        ),
                        TextFormField(
                            decoration: const InputDecoration(
                                icon: Icon(Icons.description),
                                hintText: 'Additional details',
                                labelText: 'Listing description'
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Cannot be blank';
                              }
                              _descr = value;
                              return null;
                            }
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.equalizer),
                                    labelText: 'Quantity',
                                    hintText: '# of portions'
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value){
                                  if (value == '') {
                                    return 'Cannot be blank';
                                  }
                                  if (int.parse(value) <= 0) {
                                    return 'Cannot be 0 or negative';
                                  }
                                  _quantity = int.parse(value);
                                  return null;
                                },
                              ),
                            ),
                            Flexible(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.person),
                                      labelText: 'Limit/person',
                                      hintText: '0 for no limit'
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Cannot be blank';
                                    }
                                    if (int.parse(value) < 0) {
                                      return 'Cannot be negative. Use 0 for no limit';
                                    }
                                    _limit = int.parse(value);
                                    return null;
                                  },
                                )
                            )
                          ],
                        ),
                        SizedBox(height: 7.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.location_on),
                                    labelText: 'Latitude',
                                    hintText: 'Latitude'
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value){
                                  if (value == '') {
                                    return 'Cannot be blank';
                                  }
                                  _lat = double.parse(value);
                                  return null;
                                },
                                controller: txtLat,
                              ),
                            ),
                            Flexible(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.location_on),
                                      labelText: 'Longitude',
                                      hintText: 'Longitude'
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Cannot be blank';
                                    }
                                    _lon = double.parse(value);
                                    return null;
                                  },
                                  controller: txtLon,
                                )
                            )
                          ],
                        ),
                        SizedBox(height: 5.0),
                        FlatButton(
                            onPressed: (){
                              MyLocation _gloc = new MyLocation();
                              _gloc.get().then((Map<String, double> _locd) {
                                txtLat.text = _locd['latitude'].toString();
                                txtLon.text = _locd['longitude'].toString();
                              });
                            },
                            child: Text('CURRENT LOCATION')
                        ),
                        SizedBox(height: 7.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context)

                            ),
                            IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () => _selectTime(context)
                            ),
                            Text(
                                '${_selectedDateS.year}/${_selectedDateS.month.toString().padLeft(2, "0")}/${_selectedDateS.day.toString().padLeft(2, "0")} $_timeS'
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _selectDateT(context)

                            ),
                            IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () => _selectTimeT(context)
                            ),
                            Text(
                                '${_selectedDateT.year}/${_selectedDateT.month.toString().padLeft(2, "0")}/${_selectedDateT.day.toString().padLeft(2, "0")} $_timeT'
                            ),
                          ],
                        ),

                        SizedBox(height: 25.0),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: getImage,
                        ),
                        /*Image.asset(
                  _image,
                  height: 100,
                  width: 100,
                ),*/
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: _imgs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return new Container(
                                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                    child: Image.file(
                                      _imgs[index],
                                      height: 150,
                                      //width: 150,
                                    )

                                );
                              }
                          ),
                        ),
                        SizedBox(height: 25.0),
                        RaisedButton(
                            child: Text('SUBMIT'),
                            onPressed: _submitForm
                        )
                      ]
                  )
              )
            ]
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
                  Navigator.of(context).pop();
                  //Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }
}