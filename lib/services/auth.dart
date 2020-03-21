import 'package:firebase_auth/firebase_auth.dart';
import 'package:teavault/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> get currentUser {
    return _auth.currentUser();
  }

  Future<FirebaseUser> signInAnonymously() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      print('Attempting to load user profile for uid "${result.user.uid}"');

      //Attempt to load existing user profile
      if (await fetchUserProfile() == null) {
        print('Could not find existing profile for user.\nCreating new profile...');
        await initialiseNewUserProfile();
        print('Success.');
      };
      print('Signed in anonymously as user "${result.user.uid}"');
    } catch (err) {
      throw AuthException(null, "Anonymous authentication failed: ${err.toString()}");
    }

    return currentUser;
  }

//  email signin

//email register

  Future signOut() async {
    await _auth.signOut();
  }
}
