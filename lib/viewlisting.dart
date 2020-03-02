import 'package:flutter/material.dart';
import 'package:mmo_foodapp/main.dart';
import 'package:mmo_foodapp/auth.dart';

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
  var dbHandler = new Db();

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
                ),
                SizedBox(height: 50.0),
                FlatButton(
                  child: Text(
                    'DELETE'
                  ),
                  onPressed: () {
                    _showDialog(context, 'Are you sure?', 'Once a listing is deleted, you cannot get it back.');
                  }
                )
              ],
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
                child: new Text('Delete'),
                onPressed: () {
                  dbHandler.deleteListing(_listing.documentID);
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home(_email, _name, _sex, _age)), (Route route) => false);
                }
              ),
              new RaisedButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }
}