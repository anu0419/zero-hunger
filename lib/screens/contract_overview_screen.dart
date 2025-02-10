import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerohungerr/models/contract_models.dart';
import '../services/contract_service.dart';

class ContractsOverviewScreen extends StatefulWidget {
  final String userId;
  final String userRole; // Can be "Farmer", "Manufacturer", "Retailer", "Distributor"

  ContractsOverviewScreen({required this.userId, required this.userRole});

  @override
  _ContractsOverviewScreenState createState() => _ContractsOverviewScreenState();
}

class _ContractsOverviewScreenState extends State<ContractsOverviewScreen> {
  final ContractService _contractService = ContractService();

  Stream<List<Contract>> getContracts() {
    if (widget.userRole == "Farmer") {
      return _contractService.getContractsStreamByFarmer(widget.userId);
    } else if (widget.userRole == "Manufacturer") {
      return _contractService.getContractsStreamByManufacturer(widget.userId);
    } else {
      return _contractService.getAllContractsStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contracts Overview")),
      body: StreamBuilder<List<Contract>>(
        stream: getContracts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final contracts = snapshot.data!;
          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return Card(
                child: ListTile(
                  title: Text("${contract.product} - ${contract.quantity} units"),
                  subtitle: Text("Status: ${contract.status}\nPrice: ${contract.price}"),
                  trailing: contract.status == "Pending" && widget.userRole == "Manufacturer"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => _contractService.updateContractStatus(contract.contractId, "Approved"),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _contractService.updateContractStatus(contract.contractId, "Rejected"),
                            ),
                          ],
                        )
                      : Text(contract.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
