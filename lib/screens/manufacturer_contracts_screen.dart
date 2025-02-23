import 'package:flutter/material.dart';
import 'package:zerohungerr/models/contract_models.dart';
import '../services/contract_service.dart';

class ManufacturerContractsScreen extends StatefulWidget {
  final String manufacturerId;
  ManufacturerContractsScreen({required this.manufacturerId});

  @override
  _ManufacturerContractsScreenState createState() => _ManufacturerContractsScreenState();
}

class _ManufacturerContractsScreenState extends State<ManufacturerContractsScreen> {
  final ContractService _contractService = ContractService();
  List<Contract> contracts = [];

  @override
  void initState() {
    super.initState();
    fetchContracts();
  }

  void fetchContracts() async {
    List<Contract> fetchedContracts = await _contractService.getContractsByManufacturer(widget.manufacturerId);
    setState(() {
      contracts = fetchedContracts;
    });
  }

  void approveContract(String contractId) async {
    await _contractService.updateContractStatus(contractId, "Approved");
    fetchContracts();
  }

  void rejectContract(String contractId) async {
    await _contractService.updateContractStatus(contractId, "Rejected");
    fetchContracts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending Contracts")),
      body: ListView.builder(
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${contracts[index].product} - ${contracts[index].quantity} units"),
            subtitle: Text("Price: ${contracts[index].price}, Status: ${contracts[index].status}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => approveContract(contracts[index].contractId)),
                IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => rejectContract(contracts[index].contractId)),
              ],
            ),
          );
        },
      ),
    );
  }
}
