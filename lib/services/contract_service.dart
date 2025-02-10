import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerohungerr/models/contract_models.dart';

class ContractService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new contract
  Future<void> createContract(Contract contract) async {
    await _firestore.collection('contracts').doc(contract.contractId).set(contract.toMap());
  }

  // Get contracts by farmer ID (Future, not real-time)
  Future<List<Contract>> getContractsByFarmer(String farmerId) async {
    QuerySnapshot query = await _firestore
        .collection('contracts')
        .where('farmerId', isEqualTo: farmerId)
        .get();
    return query.docs
        .map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get contracts by manufacturer ID (Future, not real-time)
  Future<List<Contract>> getContractsByManufacturer(String manufacturerId) async {
    QuerySnapshot query = await _firestore
        .collection('contracts')
        .where('manufacturerId', isEqualTo: manufacturerId)
        .get();
    return query.docs
        .map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update contract status
  Future<void> updateContractStatus(String contractId, String status) async {
    await _firestore.collection('contracts').doc(contractId).update({'status': status});
  }

  // ✅ Stream for farmer contracts (Real-time)
  Stream<List<Contract>> getContractsStreamByFarmer(String farmerId) {
    return _firestore
        .collection('contracts')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ✅ Stream for manufacturer contracts (Real-time)
  Stream<List<Contract>> getContractsStreamByManufacturer(String manufacturerId) {
    return _firestore
        .collection('contracts')
        .where('manufacturerId', isEqualTo: manufacturerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ✅ Stream for all contracts (Retailers, Distributors, etc.) (Real-time)
  Stream<List<Contract>> getAllContractsStream() {
    return _firestore.collection('contracts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Contract.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}

// ✅ Check and Expire Contracts
  Future<void> checkAndExpireContracts() async {
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
