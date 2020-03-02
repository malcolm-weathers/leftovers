import 'package:flutter/material.dart';

class ViewListing extends StatefulWidget {
  String _email, _name, _sex;
  int _age;
  String _title;

  ViewListing(this._email, this._name, this._sex, this._age, this._title);

  @override
  ViewListingState createState() => ViewListingState(_email, _name, _sex, _age, _title);
}

class ViewListingState extends State<ViewListing> {
  String _email, _name, _sex;
  int _age;
  String _title;

  ViewListingState(this._email, this._name, this._sex, this._age, this._title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

          ]
        )
    );
  }
}