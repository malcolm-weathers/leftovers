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

  Future<List<DocumentSnapshot>> getListings(String email) async {
    var result = await Firestore.instance.collection('listings').where('email', isEqualTo: email).getDocuments();
    print('returning ${result.documents}');
    return result.documents;
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
}