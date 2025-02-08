import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerohungerr/auth_service.dart';
import 'package:zerohungerr/screens/signup_screen.dart';
import 'dashboard_farmer.dart';
import 'dashboard_manufacturer.dart';
import 'dashboard_distributor.dart';
import 'dashboard_retailer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'Farmer';
  bool _isLoading = false;
  bool isPasswordHidden = true;

  // Function to handle login
  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get user role
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        String userRole = userDoc["role"];
        print("User Role: $userRole");

        navigateToDashboard(userCredential.user!.uid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No user role found! Please contact support."),
        ));
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login Failed: ${e.toString()}'),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Function to navigate based on role
  void navigateToDashboard(String uid) async {
    String? role = await authService.getUserRole(uid);
    if (role == "Farmer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FarmerDashboard()));
    } else if (role == "Manufacturer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ManufacturerDashboard()));
    } else if (role == "Distributor") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DistributorDashboard()));
    } else if (role == "Retailer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RetailerDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Zero Hunger',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Don't have an account? "),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                  },
                  child: const Text(
                    "Signup here",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
