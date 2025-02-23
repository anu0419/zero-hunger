import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractListScreen extends StatelessWidget {
  void updateContractStatus(String contractId, String newStatus) {
    FirebaseFirestore.instance.collection('contracts').doc(contractId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Contracts')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('contracts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var contracts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              var contract = contracts[index];
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
                        "Status: ${contract['status']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: contract['status'] == 'Pending'
                              ? Colors.orange
                              : contract['status'] == 'Accepted'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: contract['status'] == 'Pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  updateContractStatus(contract.id, 'Accepted'),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  updateContractStatus(contract.id, 'Rejected'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
