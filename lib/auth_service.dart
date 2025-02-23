import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user; // Get the user instance

      if (user != null) {
        // Store additional user data (name, role) in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'role': role, // Role determines if user is Admin or User
          'profilePic': '', // Add default or let user upload
          'contracts': [],
          'warnings': [],
        });
        return null; // Success
      } else {
        return "User creation failed.";
      }
    } catch (e) {
      return e.toString(); // Return the exception message
    }
  }

  // Function to register user with Firestore after signup
  Future<void> registerUser(
      String name, String email, String password, String role) async {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'name': name,
      'email': email,
      'role': role,
      'profilePic': '', // Add default or let user upload
      'contracts': [],
      'warnings': []
    });

    print("User registered successfully!");
  }

  // Function to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch the user's role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        return userDoc['role'] as String; // Return the role (Admin/User)
      } else {
        return "User role not found.";
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  // Function to get user role
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc['role'] as String : null;
  }

  // Function for user logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
