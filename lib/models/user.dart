import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot> fetchUser() async {
  final user = await FirebaseAuth.instance.currentUser();
  final userDbRecordSet =
      await Firestore.instance.collection('users').where('uid', isEqualTo: user.uid).limit(1).getDocuments();
  final userDbRecord = userDbRecordSet.documents[0];
  return userDbRecord;
}

Future<DocumentSnapshot> initialiseNewUser() async {
  final userAuth = await FirebaseAuth.instance.currentUser();
  final userDbRecord = await Firestore.instance.collection('users').add(createUserJson(userAuth));
  return userDbRecord.get();
}

Map<String, dynamic> createUserJson(FirebaseUser user) {
  return {
    'uid': user.uid,
    'username': 'Username Placeholder',
    'display_name': 'Display Name Placeholder',
  };
}
