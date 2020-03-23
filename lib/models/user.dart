import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teavault/services/auth.dart';

Future<DocumentSnapshot> fetchUserProfile() async {
  if (authService.lastKnownUser == null) {
    return null;
  }

  try {
    final userDbRecordSet = await Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: authService.lastKnownUser.uid)
        .getDocuments();
    if (userDbRecordSet.documents.length > 1) {
      throw RangeError('Duplicate documents exist for user ${authService.lastKnownUser.uid} in the users collection');
    }
    return userDbRecordSet.documents[0];
  } on RangeError catch (err) {
    print(err);
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
