import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData?['profilePic'] != null && userData?['profilePic'].isNotEmpty
                        ? NetworkImage(userData!['profilePic'])
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text("Name: ${userData?['name']}", style: TextStyle(fontSize: 18)),
                  Text("Email: ${userData?['email']}", style: TextStyle(fontSize: 18)),
                  Text("Role: ${userData?['role']}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),

                  // 🔥 **Warnings List (Added StreamBuilder)**
                  Text("Warnings:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('warnings')
                        .where('userId', isEqualTo: user!.uid)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      if (snapshot.data!.docs.isEmpty) return Text("No warnings found.");
                      
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          return ListTile(
                            title: Text(doc['risk_type']),
                            subtitle: Text("Risk Level: ${doc['risk_level']}"),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }
}
