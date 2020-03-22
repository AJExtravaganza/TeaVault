import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teavault/models/user.dart';

class AuthService {
  //Singleton class to allow global access
  static final AuthService _authService = new AuthService._internal();

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //These two members provide instantaneous synchronous access to what should in all cases be the current user/profile
  FirebaseUser _lastKnownUser;
  String _lastKnownUserProfileId;


  Future<FirebaseUser> get currentUser {
    return _auth.currentUser().then((user) => _lastKnownUser = user);
  }

  FirebaseUser get lastKnownUser => _lastKnownUser;
  String get lastKnownUserProfileId => _lastKnownUserProfileId;

  Future<FirebaseUser> signInAnonymously() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      _lastKnownUser = result.user;
      print('Attempting to load user profile for uid "${result.user.uid}"...');

      final userProfile = await fetchUserProfile();
      if (await fetchUserProfile() != null) {
        _lastKnownUserProfileId = userProfile.documentID;
        print('Success.');
      } else {
        print('Could not find existing profile for user.\nCreating new profile...');
        final newUserProfile = await initialiseNewUserProfile();
        _lastKnownUserProfileId = newUserProfile.documentID;
        print('Success.');
      }
      print('Signed in anonymously as user "${result.user.uid} with users document id ${_lastKnownUserProfileId}"');
    } catch (err) {
      _lastKnownUser = null;
      _lastKnownUserProfileId = null;
      throw AuthException(null, "Anonymous authentication failed: ${err.toString()}");
    }

    return currentUser;
  }

//  email signin

//email register

  Future signOut() async {
    _lastKnownUser = null;
    _lastKnownUserProfileId = null;
    await _auth.signOut();
  }
}

final authService = AuthService();
