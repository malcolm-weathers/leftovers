import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mmo_foodapp/main.dart';
import 'package:mmo_foodapp/getlocation.dart';
import 'package:mmo_foodapp/auth.dart';

class MakeListing extends StatefulWidget {
  String _email, _name, _sex;
  int _age;

  MakeListing(this._email, this._name, this._sex, this._age);
  @override
  MakeListingState createState() => MakeListingState(_email, _name, _sex, _age);
}

class MakeListingState extends State<MakeListing> {
  String _email, _name, _sex;
  int _age;
  String _title, _descr;
  int _quantity, _limit;
  double _lat, _lon;

  var _imgs = [];

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var txtLat = TextEditingController();
  var txtLon = TextEditingController();
  var dbHandler = new Db();

  String _time_s, _time_t;

  DateTime selectedDate_s = DateTime.now();
  DateTime selectedDate_t = DateTime.now();
  TimeOfDay selectedTime_s = TimeOfDay.now();
  TimeOfDay selectedTime_t = TimeOfDay.now();

  MakeListingState(this._email, this._name, this._sex, this._age);

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate() && _time_s != null && _time_t != null) {
      form.save();

      DateTime dss = DateTime.utc(selectedDate_s.year, selectedDate_s.month, selectedDate_s.day,
      selectedTime_s.hour, selectedTime_s.minute).toLocal().add(Duration(hours:5));
      DateTime dst = DateTime.utc(selectedDate_t.year, selectedDate_t.month, selectedDate_t.day,
          selectedTime_t.hour, selectedTime_t.minute).toLocal().add(Duration(hours:5));

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

      dbHandler.newListingMap(newListing).then((value) {
        _showDialog(context, 'Listing created', '');
      });
    } else {
      print('Listing could not be created');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate_s,
        firstDate: DateTime.now().subtract(Duration(days: 1)),// DateTime(2015, 8),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if (picked != null && picked != selectedDate_s)
      setState(() {
        selectedDate_s = picked;
      });
  }

  Future<void> _selectDate_t(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate_t,
        firstDate: DateTime.now().subtract(Duration(days: 1)),// DateTime(2015, 8),
        lastDate: DateTime.now().add(Duration(days: 7)));
    if (picked != null && picked != selectedDate_t)
      setState(() {
        selectedDate_t = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime_s,
    );
    if (picked != null && picked != selectedTime_s)
      setState(() {
        selectedTime_s = picked;
        TimeOfDay tt = selectedTime_s.replacing(hour: selectedTime_s.hourOfPeriod);
        if (selectedTime_s.hour < 12) {
          _time_s = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
        } else {
          _time_s = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
        }
      });
  }

  Future<void> _selectTime_t(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime_t,
    );
    if (picked != null && picked != selectedTime_t)
      setState(() {
        selectedTime_t = picked;
        TimeOfDay tt = selectedTime_t.replacing(hour: selectedTime_t.hourOfPeriod);
        if (selectedTime_t.hour < 12) {
          _time_t = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} AM';
        } else {
          _time_t = '${tt.hour}:${tt.minute.toString().padLeft(2, "0")} PM';
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
                    GetLocation _gloc = new GetLocation();
                    _gloc.get().then((LocationData _locd) {
                      txtLat.text = _locd.latitude.toString();
                      txtLon.text = _locd.longitude.toString();
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
                        '${selectedDate_s.year}/${selectedDate_s.month.toString().padLeft(2, "0")}/${selectedDate_s.day.toString().padLeft(2, "0")} $_time_s'
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate_t(context)

                    ),
                    IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime_t(context)
                    ),
                    Text(
                        '${selectedDate_t.year}/${selectedDate_t.month.toString().padLeft(2, "0")}/${selectedDate_t.day.toString().padLeft(2, "0")} $_time_t'
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
                      return new Image.file(
                        _imgs[index],
                        height: 150,
                        width: 150,
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
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) => Home(_email, _name, _sex, _age)), (
                      Route route) => false);
                },
              ),
            ],
          );
        }
    );
  }
}