import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mmo_foodapp/getlocation.dart';
import 'package:mmo_foodapp/auth.dart';
import 'package:mmo_foodapp/viewforeign.dart';

class Search extends StatefulWidget {
  final String _email, _name, _sex;
  final int _age;
  final List<dynamic> _claimed;

  Search(this._email, this._name, this._sex, this._age, this._claimed);
  @override
  SearchState createState() => SearchState(_email, _name, _sex, _age, _claimed);
}

class SearchState extends State<Search> {
  String _email, _name, _sex;
  int _age;
  List<dynamic> _claimed;

  var _txtLat = TextEditingController();
  var _txtLon = TextEditingController();
  var _txtRad = TextEditingController(text: '5.0');

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var dbHandler = new Db();
  List<dynamic> _inRange = [];

  SearchState(this._email, this._name, this._sex, this._age, this._claimed);

  @override
  Widget build(BuildContext context) {
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
                        //_descr = value;
                        return null;
                      },
                      controller: _txtLon,
                    ),
                  ),
                  FlatButton(
                    child: Text('CURRENT'),
                    onPressed: () {
                      GetLocation _gloc = new GetLocation();
                      _gloc.get().then((LocationData _locd) {
                        _txtLat.text = _locd.latitude.toString();
                        _txtLon.text = _locd.longitude.toString();
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
              SizedBox(height: 20.0),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _inRange.length,
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
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
                          new ViewForeign(_email, _name, _sex, _age, _claimed, _inRange[index]['id'], _inRange[index])));
                        }
                    );
                  }
              ),
            ],
          )
        )
      )
    );
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      dbHandler.getByLocation(double.parse(_txtLat.text), double.parse(_txtLon.text), double.parse(_txtRad.text)).then((List<dynamic> x){
        _inRange = x;
        setState(() {});
      });
    }
  }
}