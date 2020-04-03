import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' as imagepicker;

import 'package:leftovers/auth.dart';
import 'package:leftovers/location.dart';

class CreateListing extends StatefulWidget {
  final String _email;

  CreateListing(this._email);
  @override
  CreateListingState createState() => CreateListingState(_email);
}

class CreateListingState extends State<CreateListing> {
  String _email, _title, _descr;
  File _image;
  int _quantity, _limit;
  double _lat, _lon;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var txtLat = TextEditingController();
  var txtLon = TextEditingController();
  Auth authHandler = new Auth();

  DateTime _start = DateTime.now(), _finish = DateTime.now().add(Duration(hours: 1));
  String _startS, _finishS;

  CreateListingState(String email) {
    _email = email;
    _setTimeStrings();
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (_start.millisecondsSinceEpoch > _finish.millisecondsSinceEpoch + 3600000 && _image != null) {
      print('End time must be at least an hour after start time');
      print('At least one image must be uploaded');
    } else if (form.validate()) {
      form.save();

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
        'time_s': _start.millisecondsSinceEpoch / 1000,
        'time_t': _finish.millisecondsSinceEpoch / 1000,
        'claimed': {},
      };

      authHandler.listingSet(null, newListing).then((String docID) {
        authHandler.uploadImage(docID, _image).then((int value) {
          _showDialog(context, 'Listing created', '');
        });
      });
    } else {
      print('Listing could not be created');
    }
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

    _startS = '${_start.year}/${_start.month.toString().padLeft(2,"0")}/${_start.day.toString().padLeft(2,"0")} $_hourS:${_start.minute.toString().padLeft(2,"0")} $_amS';
    _finishS = '${_finish.year}/${_finish.month.toString().padLeft(2,"0")}/${_finish.day.toString().padLeft(2,"0")} $_hourT:${_finish.minute.toString().padLeft(2,"0")} $_amT';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _start,
        firstDate: DateTime.now().subtract(Duration(hours: 1)),
        lastDate: DateTime.now().add(Duration(days: 7))
    );
    if (picked != null)
      setState(() {
        _start = picked;
        _setTimeStrings();
      });
  }

  Future<void> _selectDateT(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _finish,
        firstDate: DateTime.now().subtract(Duration(hours: 1)),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if (picked != null)
      setState(() {
        _finish = picked;
        _setTimeStrings();
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _start = DateTime.utc(_start.year, _start.month, _start.day, picked.hour, picked.minute);
        _setTimeStrings();
      });
    }
  }

  Future<void> _selectTimeT(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
    );
    if (picked != null) {
      setState(() {
        _finish = DateTime.utc(_finish.year, _finish.month, _finish.day, picked.hour, picked.minute);
        _setTimeStrings();
      });
    }
  }

  Future getImage() async {
    File _x = await imagepicker.ImagePicker.pickImage(
      source: imagepicker.ImageSource.gallery,
    );
    if (_x == null) {
      return;
    }
    File _cropped = await ImageCropper.cropImage(
      sourcePath: _x.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxHeight: 600,
      maxWidth: 600,
    );
    if (_cropped == null) {
      return;
    }
    setState(() {
      _image = _cropped;
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
                          hintText: 'Blank for no limit'
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == '') {
                            _limit = 0;
                            return null;
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
                Text('Pickup start time:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('$_startS'),
                    SizedBox(width: 15.0),
                    RaisedButton(
                        child: Text('CHANGE'),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _selectTime(context);
                          _selectDate(context);
                        }
                    )
                  ],
                ),
                SizedBox(height: 7.5),
                Text('Pickup end time:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('$_finishS'),
                    SizedBox(width: 15.0),
                    RaisedButton(
                        child: Text('CHANGE'),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _selectTimeT(context);
                          _selectDateT(context);
                        }
                    )
                  ],
                ),
                SizedBox(height: 25.0),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: getImage,
                ),
                Container(
                  child: _image == null ? Image.asset('assets/icon.png',height:150) : Image.file(_image,height:150)
                ),
                /*SizedBox(
                  height: 150.0,
                  child: FadeInImage.memoryNetwork(
                    placeholder: 'assets/icon.png',
                    image: _imagePath,
                  ),
                ),*/

                /*ListView.builder(
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
                ),*/
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
              },
            ),
          ],
        );
      }
    );
  }
}