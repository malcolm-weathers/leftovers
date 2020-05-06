import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> userLogin(String email, String password) async {
    AuthResult result = await auth.signInWithEmailAndPassword(email: email, password: password);
    final FirebaseUser user = result.user;
    await user.getIdToken();
    final FirebaseUser currentUser = await auth.currentUser();
    if (currentUser.uid == user.uid) {
      return true;
    }
    return false;
  }

  Future<bool> userRegister(String email, String password, Map<String, dynamic> data) async {
    AuthResult _result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    if (_result.user != null) {
      await Firestore.instance.collection('users').document(email.replaceAll('.', ',')).setData(data);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> userDataGet(String email) async {
    var result = await Firestore.instance.collection('users').document(email.replaceAll('.', ',')).get();
    return result.data;
  }

  Future<int> userDataSet(String email, Map<String, dynamic> data) async {
    await Firestore.instance.collection('users').document(email.replaceAll('.', ',')).setData(data);
    return 0;
  }

  Future<int> listingDelete(String docID) async {
    await Firestore.instance.collection('listings').document(docID).delete();
    return 0;
  }

  Future<String> listingSet(String id, Map<String, dynamic> data) async {
    var x = Firestore.instance.collection('listings').document(id);
    await x.setData(data);
    return x.documentID;
  }

  Future<Map<String, dynamic>> listingGet(String id) async {
    DocumentSnapshot _doc = await Firestore.instance.collection('listings').document(id).get();
    return Map<String, dynamic>.from(_doc.data);
  }

  Future<List<Map<String, dynamic>>> listingsGetByUser(String email) async {
    QuerySnapshot _snap = await Firestore.instance.collection('listings').where('email', isEqualTo: email).getDocuments();
    List<Map<String, dynamic>> _results = [];
    _snap.documents.forEach((DocumentSnapshot _item) {
      Map<String, dynamic> _data = _item.data;
      _data['id'] = _item.documentID;
      _results.add(_data);
    });
    return _results;
  }

  Future<List<Map<String, dynamic>>> listingsGetByUserFuture(String email) async {
    QuerySnapshot _snap = await Firestore.instance.collection('listings').where('email', isEqualTo: email).getDocuments();
    List<Map<String, dynamic>> _results = [];
    _snap.documents.forEach((DocumentSnapshot _item) {
      Map<String, dynamic> _data = _item.data;
      _data['id'] = _item.documentID;
      if (_data['time_t'] > DateTime.now().millisecondsSinceEpoch / 1000) {
        _results.add(_data);
      }
    });
    return _results;
  }

  Future<List<Map<String, dynamic>>> listingsGetByUserPast(String email) async {
    QuerySnapshot _snap = await Firestore.instance.collection('listings').where('email', isEqualTo: email).getDocuments();
    List<Map<String, dynamic>> _results = [];
    _snap.documents.forEach((DocumentSnapshot _item) {
      Map<String, dynamic> _data = _item.data;
      _data['id'] = _item.documentID;
      if (_data['time_t'] < DateTime.now().millisecondsSinceEpoch / 1000) {
        _results.add(_data);
      }
    });
    return _results;
  }

  Future<List<Map<String, dynamic>>> listingsGetByLocation(double lat, double lon, double rad) async {
    double _lat0 = lat - (rad/69.2), _lat1 = lat + (rad/69.2);

    QuerySnapshot _snap = await Firestore.instance.collection('listings').where('location.latitude', isGreaterThanOrEqualTo: _lat0).where('location.latitude', isLessThanOrEqualTo: _lat1).getDocuments();
    List<Map<String, dynamic>> _results = [];
    _snap.documents.forEach((DocumentSnapshot _item) {
      Map<String, dynamic> _data = _item.data;
      _data['id'] = _item.documentID;
      double _dist = (lat - _data['location']['latitude']).abs() * 69.2 + (lon - _data['location']['longitude']).abs() * 69.2;
      if (_dist < rad) {
        _data['distance'] = double.parse(_dist.toStringAsFixed(1));
        _results.add(_data);
      } else {
        print('$_dist is greater than $rad');
      }
    });
    return _results;
  }

  Future<List<Map<String, dynamic>>> listingsGetByLocationNF(double lat, double lon, double rad) async {
    double _lat0 = lat - (rad/69.2), _lat1 = lat + (rad/69.2);

    QuerySnapshot _snap = await Firestore.instance.collection('listings').where('location.latitude', isGreaterThanOrEqualTo: _lat0).where('location.latitude', isLessThanOrEqualTo: _lat1).getDocuments();
    List<Map<String, dynamic>> _results = [];
    _snap.documents.forEach((DocumentSnapshot _item) {
      Map<String, dynamic> _data = _item.data;
      _data['id'] = _item.documentID;
      double _dist = (lat - _data['location']['latitude']).abs() * 69.2 + (lon - _data['location']['longitude']).abs() * 69.2;
      if (_dist < rad) {
        _data['distance'] = double.parse(_dist.toStringAsFixed(1));
        int _remaining = _data['quantity'];
        _data['claimed'].forEach((String key, dynamic value) {
          if (_data['claimed'][key]['status'] != 'cancelled')
            _remaining -= value['no'];
        });
        if (_remaining > 0) {
          _results.add(_data);
        }
      } else {
        print('$_dist is greater than $rad');
      }
    });
    return _results;
  }

  Future<int> uploadImage(String docID, File image) async {
    String _fname = docID+'/0.jpg';
    StorageReference storage = FirebaseStorage().ref().child(_fname);
    StorageUploadTask uploadTask = storage.putData(image.readAsBytesSync());
    await uploadTask.onComplete;
    //}
  }

  Future<Uint8List> getImage0(String docID) async {
    print('getting 0.jpg for $docID');
    StorageReference storage = FirebaseStorage().ref().child(docID+'/0.jpg');
    Uint8List x = await storage.getData(1024*1024*8);
    return x;
  }

  Future<int> imageDelete(String docID) async {
    StorageReference _storage = FirebaseStorage().ref().child(docID+'/0.jpg');
    await _storage.delete();
    return 0;
  }
}