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
  String _email, _name, _sex, _times, _timet;
  int _age, _remaining;
  var _listing;
  var dbHandler = new Db();

  ViewListingState(String email, String name, String sex, int age, var listing) {
    this._email = email;
    this._name = name;
    this._sex = sex;
    this._age = age;
    this._listing = listing;
    this._remaining = listing["quantity"];

    listing["claimed"].forEach((String key, dynamic value){
      _remaining -= value;
    });

    String hours, hourt;
    var ds = DateTime.fromMillisecondsSinceEpoch(listing["time_s"].seconds*1000).toLocal();
    _times = '${ds.year}-${ds.month.toString().padLeft(2, '0')}-${ds.day.toString().padLeft(2, '0')} ${ds.hour.toString().padLeft(2, '0')}:${ds.minute.toString().padLeft(2, '0')}';
    ds = DateTime.fromMillisecondsSinceEpoch(listing["time_t"].seconds*1000).toLocal();
    _timet = '${ds.year}-${ds.month.toString().padLeft(2, '0')}-${ds.day.toString().padLeft(2, '0')} ${ds.hour.toString().padLeft(2, '0')}:${ds.minute.toString().padLeft(2, '0')}';
  }

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
                  '$_times\n-\n$_timet',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                FlatButton(
                  child: Text(
                    'DELETE LISTING'
                  ),
                  onPressed: () {
                    _showDialog(context, 'Are you sure?', 'Once a listing is deleted, you cannot get it back.');
                  }
                ),
                SizedBox(height: 20.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _listing["claimed"].length,
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0, bottom: 0.0),
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${_listing['claimed'].keys.elementAt(index)}: ${_listing['claimed'].values.elementAt(index).toString()}",
                          textScaleFactor: 1.1,
                        ),
                        IconButton(
                          icon: Icon(Icons.check_circle),
                          onPressed: (){

                          },
                        ),
                        //SizedBox(width: 5.0),
                        IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            String u = _listing['claimed'].keys.elementAt(index);
                            var newdata =_listing.data;
                            newdata['claimed'].remove(u);
                            print(newdata);
                            dbHandler.setListing2(_listing.documentID, _listing.data).then((int value){
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new ViewListing(_email, _name, _sex, _age, newdata)));
                              //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ViewListing(_email, _name, _sex, _age, _listing)), (Route route) => false);
                            });
                            //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ViewListing(_email, _name, _sex, _age, _listing)), (Route route) => false);
                          }
                        )
                      ],
                    );
                  }
                ),
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