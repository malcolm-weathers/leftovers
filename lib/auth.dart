import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<FirebaseUser> handleSignIn(String email, String password) async {
    AuthResult result = await auth.signInWithEmailAndPassword(
        email: email, password: password);
    final FirebaseUser user = result.user;
    await user.getIdToken();
    final FirebaseUser currentUser = await auth.currentUser();
    if (currentUser.uid == user.uid) {
      return user;
    }
    return null;
  }

  Future<FirebaseUser> handleRegister(String email, String password) async {
    AuthResult result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final FirebaseUser user = result.user;
    return user;
  }
}

class Db {
  Future<Map<String, dynamic>> getValues(String email) async {
    String emailFixed = email.replaceAll('.',',');
    var result = await Firestore.instance.collection('users').document(emailFixed).get();
    return result.data;
  }

  void setUserData(String email, Map<String, dynamic> data) async {
    String emailFixed = email.replaceAll('.', ',');
    await Firestore.instance.collection('users').document(emailFixed).setData(data);
  }

  Future<List<dynamic>> getListings(String email) async {
    var result = await Firestore.instance.collection('listings').where('email', isEqualTo: email).getDocuments();
    return result.documents;
  }

  void deleteListing(String docID) async {
    await Firestore.instance.collection('listings').document(docID).delete();
  }

  Future<Map<String, dynamic>> getListing(String id) async {
    var x = await Firestore.instance.collection('listings').document(id).get();
    return Map<String, dynamic>.from(x.data);
  }

  Future<int> newListingMap(Map<String, dynamic> data) async {
    await Firestore.instance.collection('listings').document().setData(data);
    return 0;
  }

  Future<int> setListingMap(String id, Map<String, dynamic> data) async {
    await Firestore.instance.collection('listings').document(id).setData(data);
    return 0;
  }

  void setListing(String email, String title, String descr, int quantity, int limit, double lat, double lon) async {
    await Firestore.instance.collection('listings').document().setData({
      'email': email,
      'title': title,
      'descr': descr,
      'quantity': quantity,
      'limit': limit,
      'location': {
        'latitude': lat,
        'longitude': lon
      }
    });
  }

  Future<List<dynamic>> getByLocation(double lat, double lon, double rad) async {
    double _lat0 = lat - (rad/69.2), _lat1 = lat + (rad/69.2), _lon0 = lon - (rad/69.2), _lon1 = lon + (rad/69.2);
    print('Retrieving locations w/in $_lat0 to $_lat1 N and $_lon0 to $_lon1 east');

    var x = await Firestore.instance.collection('listings')
        .where('location.latitude', isGreaterThanOrEqualTo: _lat0)
        .where('location.latitude', isLessThanOrEqualTo: _lat1)
        .getDocuments();
    List<dynamic> results = [];
    x.documents.forEach((var item){
      var _d = item.data;
      _d['id'] = item.documentID;
      double _dist = (lat - _d['location']['latitude']).abs() / 69.2 + (lat - _d['location']['longitude']).abs() / 69.2;
      if (_dist < rad) {
        _d['distance'] = double.parse(_dist.toStringAsFixed(1));
        results.add(_d);
      }
    });

    return results;
  }
}