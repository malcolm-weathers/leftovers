import 'package:flutter/material.dart';

class ViewListing extends StatefulWidget {
  String _email, _name, _sex;
  int _age;
  String _title, _descr;

  ViewListing(this._email, this._name, this._sex, this._age, this._title, this._descr);

  @override
  ViewListingState createState() => ViewListingState(_email, _name, _sex, _age, _title, _descr);
}

class ViewListingState extends State<ViewListing> {
  String _email, _name, _sex;
  int _age;
  String _title, _descr;

  ViewListingState(this._email, this._name, this._sex, this._age, this._title, this._descr);

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
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
              children: <Widget>[
                Text(_descr,
                    style: TextStyle(
                        fontSize: 20.0
                    )
                )
              ],
            )

          ]
        )
    );
  }
}