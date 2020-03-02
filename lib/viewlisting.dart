import 'package:flutter/material.dart';

class ViewListing extends StatefulWidget {
  String _email, _name, _sex;
  int _age;
  var _listing;

  ViewListing(this._email, this._name, this._sex, this._age, this._listing);

  @override
  ViewListingState createState() => ViewListingState(_email, _name, _sex, _age, _listing);
}

class ViewListingState extends State<ViewListing> {
  String _email, _name, _sex;
  int _age;
  var _listing;

  ViewListingState(this._email, this._name, this._sex, this._age, this._listing);

  @override
  Widget build(BuildContext context) {
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
                    )
                ),
                Text(
                  'Quantity: ${_listing["quantity"]}'
                ),
                Text(
                  'Limit/person: ${_listing["limit"]}'
                ),
                Text(
                  'Latitude: ${_listing["location"]["latitude"]}\nLongitude: ${_listing["location"]["longitude"]}'
                )
              ],
            )

          ]
        )
    );
  }
}