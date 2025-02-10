import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerohungerr/screens/contract_overview_screen.dart';
import 'package:zerohungerr/screens/addcontractscreen.dart';
import 'package:zerohungerr/screens/contract_creation_screen.dart';

class FarmerDashboard extends StatefulWidget {
  final String farmerId;
  FarmerDashboard({required this.farmerId});

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  void signContract(String contractId) {
    FirebaseFirestore.instance.collection('contracts').doc(contractId).update({
      'farmerSignature': true,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have signed the contract!")),
      );
    });
  }

  void terminateContract(String contractId) {
  FirebaseFirestore.instance.collection('contracts').doc(contractId).update({
    'status': 'Terminated',
  }).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contract Terminated!")),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Farmer Dashboard")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContractListScreen()),
                    );
                  },
                  child: Text('View Contracts'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddContractScreen()),
                    );
                  },
                  child: Text('Add Contract'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('contracts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var contracts = snapshot.data!.docs;

                if (contracts.isEmpty) {
                  return Center(child: Text("No Contracts Available"));
                }

                return ListView.builder(
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    var contract = contracts[index];
                    
                    Map<String, dynamic>? contractData = contract.data() as Map<String, dynamic>?;

                    String contractStatus = contractData != null && contractData.containsKey('status')
                        ? contractData['status']
                        : "Unknown";

                    print("Contract Data: ${contract.data()}");

                    
                    String farmerSignature = (contractData != null && contractData.containsKey('farmerSignature'))
                        ? contractData['farmerSignature'].toString()
                        : "No Signature Available";
                    
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(contract['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contract['description']),
                            SizedBox(height: 5),
                            Text(
                              "Status: $contractStatus",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: contractStatus == "Finalized"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            SizedBox(height: 5),
                            farmerSignature == "true"
                                ? Text("✅ Signed by Farmer", style: TextStyle(color: Colors.green))
                                : ElevatedButton(
                                    onPressed: () => signContract(contract.id),
                                    child: Text("Sign Contract"),
                                  ),

                             SizedBox(height: 5),
                             // ✅ Added Terminate Button based on contract status
                             contract['status'] == "Active"
                              ? ElevatedButton(
                                  onPressed: () => terminateContract(contract.id),
                                  child: Text("Terminate Contract"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                )
                              : Text("❌ Contract ${contract['status']}", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
