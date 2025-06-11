import '/exports.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth methods
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  // Firestore methods
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get productsCollection => _firestore.collection('products');
  CollectionReference get ordersCollection => _firestore.collection('orders');
  CollectionReference get cartsCollection => _firestore.collection('carts');

  // Create document
  Future<void> createDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  // Update document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Get document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Get documents with query
  Future<QuerySnapshot> getDocuments(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) async {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  // Listen to document
  Stream<DocumentSnapshot> listenToDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Listen to documents
  Stream<QuerySnapshot> listenToDocuments(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Storage methods
  // Upload file to Firebase Storage
  Future<String> uploadFile(String path, Uint8List fileBytes, {String? fileName}) async {
    try {
      fileName ??= DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(fileBytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  // Upload image from file
  Future<String> uploadImage(String path, Uint8List imageBytes, {String? fileName}) async {
    return await uploadFile('images/$path', imageBytes, fileName: fileName);
  }

  // Delete file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  // Handle auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return e.message ?? 'An error occurred';
    }
  }

}
