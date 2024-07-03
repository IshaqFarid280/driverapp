import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference driversCollection =
  FirebaseFirestore.instance.collection('drivers');

  Future<void> createUser(String uid, String email, String pass) async {
    return await usersCollection.doc(uid).set({
      'email': email,
      'role': 'passenger',
      'pass': pass,
    });
  }

  Future<void> createDriver(String uid, String email, String carModel, String pass) async {
    return await driversCollection.doc(uid).set({
      'email': email,
      'role': 'driver',
      'carModel': carModel,
      'password' : pass
      // Add more fields for photos and documents
    });
  }

  Future<void> switchToDriver(String uid, String email, String carModel, pass) async {
    // await usersCollection.doc(uid).delete();
    return await createDriver(uid, email, carModel, pass);
  }

  Future<void> switchToPassenger(String uid, String email, pass) async {
    // await driversCollection.doc(uid).delete();
    return await createUser(uid, email,pass);
  }

  Future<DocumentSnapshot> getUserDetails(String uid) async {
    DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
    if (userDoc.exists) {
      return userDoc;
    } else {
      DocumentSnapshot driverDoc = await driversCollection.doc(uid).get();
      return driverDoc;
    }
  }
}
