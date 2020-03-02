import 'package:flutter/material.dart';
import 'package:location/location.dart';
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
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var txtLat = TextEditingController();
  var txtLon = TextEditingController();
  var dbHandler = new Db();

  MakeListingState(this._email, this._name, this._sex, this._age);

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      dbHandler.setListing(_email, _title, _descr, _quantity, _limit, _lat, _lon);
      _showDialog(context, 'Listing created', '');
    } else {
      print('Listing could not be created');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create listing'),
        centerTitle: true,
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