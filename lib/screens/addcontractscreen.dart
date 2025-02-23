import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Farmer Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContractListScreen()),
                );
              },
              child: Text("Manage Contracts"),
            ),
          ],
        ),
      ),
    );
  }
}

class ContractListScreen extends StatefulWidget {
  @override
  _ContractListScreenState createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contracts')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('contracts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var contracts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              var contract = contracts[index];
              return ListTile(
                title: Text(contract['title']),
                subtitle: Text(contract['description']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContractScreen()),
          );
          if (result == true) {
            setState(() {}); // Refresh contract list
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddContractScreen extends StatefulWidget {
  @override
  _AddContractScreenState createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  void _addContract() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('contracts').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'timestamp': Timestamp.now(),
      });
      Navigator.pop(context, true); // Pass true to indicate success
    }
  }

  void _saveContract()  async{
    await FirebaseFirestore.instance.collection('contracts').add({
  'title': _titleController.text,
  'description': _descriptionController.text,
  'timestamp': FieldValue.serverTimestamp(),
  'status': 'Pending',  // Default status when created
});

    // Logic to save contract (You can integrate Firebase or Supabase here)
    print('Contract Added: ${_titleController.text}, ${_descriptionController.text}');
    Navigator.pop(context); // Go back to dashboard after saving
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Contract')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Contract Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Correct usage
    
    ElevatedButton(
      onPressed: _addContract,
      child: const Text('Add Contract'),
    ),

    const SizedBox(height: 20), // Corrected again
    
    ElevatedButton(
      onPressed: _saveContract,
      child: const Text('Save Contract'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
