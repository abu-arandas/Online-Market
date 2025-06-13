import '/exports.dart';

class AuthRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Get user data from Firestore
        final userDoc = await _firebaseService.getDocument('users', user.uid);

        if (userDoc.exists) {
          final userData = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return userData;
        } else {
          throw 'User data not found';
        }
      } else {
        throw 'Login failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Create user account
  Future<UserModel> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Create user model
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firebaseService.createDocument('users', user.uid, userModel.toMap());

        // Send email verification
        await _firebaseService.sendEmailVerification();

        return userModel;
      } else {
        throw 'Account creation failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _firebaseService.currentUser;

      if (currentUser != null) {
        final userDoc = await _firebaseService.getDocument('users', currentUser.uid);

        if (userDoc.exists) {
          final userData = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return userData;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await _firebaseService.updateDocument('users', user.id, updatedUser.toMap());

      return updatedUser;
    } catch (e) {
      throw e.toString();
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(Uint8List imageBytes, String userId) async {
    try {
      return await _firebaseService.uploadImage('profiles', imageBytes, fileName: userId);
    } catch (e) {
      throw e.toString();
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseService.sendEmailVerification();
    } catch (e) {
      throw e.toString();
    }
  }

  // Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _firebaseService.authStateChanges;
  }
}
