import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerohungerr/screens/contract_overview_screen.dart';

class RetailerDashboard extends StatefulWidget {
  @override
  _RetailerDashboardState createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
 

  void checkAndExpireContracts() async {
    QuerySnapshot contracts = await FirebaseFirestore.instance.collection('contracts').get();

    for (var doc in contracts.docs) {
      var contract = doc.data() as Map<String, dynamic>;
      if (contract['expiryDate'] != null) {
        DateTime expiryDate = DateTime.parse(contract['expiryDate']);
        if (expiryDate.isBefore(DateTime.now())) {
          FirebaseFirestore.instance.collection('contracts').doc(doc.id).update({
            'status': 'Expired',
          });
        }
      }
    }
  }

  void updateContractStatus(String contractId, String status) {
    FirebaseFirestore.instance.collection('contracts').doc(contractId).update({
      'status': status,
    });
  }

  void signContract(String contractId) {
    FirebaseFirestore.instance.collection('contracts').doc(contractId).update({
      'retailerSignature': true,
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
      appBar: AppBar(title: Text('Retailer Dashboard')),
      body: StreamBuilder(
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

              // ✅ Ensure 'contract.data()' is not null before accessing keys
              var data = contract.data() as Map<String, dynamic>? ?? {};
              String status = data.containsKey('status') ? data['status'] : 'Unknown';
                
              
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? 'No Description'),
                      SizedBox(height: 5),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Finalized" ? Colors.green : Colors.orange,
                        ),
                      ),
                      SizedBox(height: 5),
                      data['retailerSignature'] == true
                          ? Text("✅ Signed by Retailer", style: TextStyle(color: Colors.green))
                          : ElevatedButton(
                              onPressed: () => signContract(contract.id),
                              child: Text("Sign Contract"),
                            ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => updateContractStatus(contract.id, 'Accepted'),
                            child: Text("Accept"),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => updateContractStatus(contract.id, 'Rejected'),
                            child: Text("Reject"),
                          ),

                          
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
