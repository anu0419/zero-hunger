import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zerohungerr/models/contract_models.dart';
import '../services/contract_service.dart';

class ContractCreationScreen extends StatefulWidget {
  final String farmerId;
  ContractCreationScreen({required this.farmerId});

  @override
  _ContractCreationScreenState createState() => _ContractCreationScreenState();
}

class _ContractCreationScreenState extends State<ContractCreationScreen> {
  final ContractService _contractService = ContractService();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController manufacturerIdController = TextEditingController();

  void createContract() async {
    String contractId = Uuid().v4();

    Contract contract = Contract(
      contractId: contractId,
      farmerId: widget.farmerId,
      manufacturerId: manufacturerIdController.text,
      product: productController.text,
      quantity: int.parse(quantityController.text),
      price: double.parse(priceController.text),
      duration: durationController.text,
      status: "Pending",
    );

    await _contractService.createContract(contract);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Contract")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: productController, decoration: InputDecoration(labelText: "Product")),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: "Quantity")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Price")),
            TextField(controller: durationController, decoration: InputDecoration(labelText: "Duration")),
            TextField(controller: manufacturerIdController, decoration: InputDecoration(labelText: "Manufacturer ID")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: createContract, child: Text("Submit Contract")),
          ],
        ),
      ),
    );
  }
}
