import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot> fetchUserProfile() async {
  final user = await FirebaseAuth.instance.currentUser();

  try {
    final userDbRecordSet =
    await Firestore.instance.collection('users').where('uid', isEqualTo: user.uid).limit(1).getDocuments();
    return userDbRecordSet.documents[0];
  } on RangeError catch (err) {
    return null;
  }
}

Future<DocumentSnapshot> initialiseNewUserProfile() async {
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
