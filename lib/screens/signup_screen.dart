import 'package:flutter/material.dart';
import 'package:zerohungerr/auth_service.dart';
import 'package:zerohungerr/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService(); // Instance for authentication logic

  // Controllers for capturing input from text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Valid roles
  final List<String> _validRoles = ['Farmer', 'Retailer', 'Manufacturer', 'Distributor'];
  String _selectedRole = 'Farmer'; // Default selected role
  bool _isLoading = false; // To show loading spinner during signup
  bool isPasswordHidden = true;

  // Signup function to handle user registration
  void _signup() async {
    // Ensure the selected role is valid
    if (!_validRoles.contains(_selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid role selected!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    // Call signup method from AuthService with user inputs
    String? result = await _authService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false; // Hide loading spinner
    });

    if (result == null) {
      // Signup successful: Navigate to LoginScreen with success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Signup Successful! Now Turn to Login'),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Signup failed: Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup Failed: $result'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to the screen
        child: SingleChildScrollView(
          // Makes the screen scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Input for email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Input for password
              TextField(
                controller: _passwordController,
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
                obscureText: isPasswordHidden, // Hide the password
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting role
              DropdownButtonFormField<String>(
                value: _validRoles.contains(_selectedRole) ? _selectedRole : null,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null && _validRoles.contains(newValue)) {
                    setState(() {
                      _selectedRole = newValue;
                      print("Selected Role: $_selectedRole"); // Debugging
                    });
                  }
                },
                items: _validRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Signup button or loading spinner
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity, // Button stretches across width
                      child: ElevatedButton(
                        onPressed: _signup, // Call signup function
                        child: const Text('Signup'),
                      ),
                    ),
              const SizedBox(height: 10),
              // Navigation to LoginScreen
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login here",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
