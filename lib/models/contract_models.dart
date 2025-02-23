class Contract {
  String contractId;
  String farmerId;
  String manufacturerId;
  String product;
  int quantity;
  double price;
  String duration;
  String status;

  Contract({
    required this.contractId,
    required this.farmerId,
    required this.manufacturerId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.duration,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'contractId': contractId,
      'farmerId': farmerId,
      'manufacturerId': manufacturerId,
      'product': product,
      'quantity': quantity,
      'price': price,
      'duration': duration,
      'status': status,
    };
  }

  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      contractId: map['contractId'],
      farmerId: map['farmerId'],
      manufacturerId: map['manufacturerId'],
      product: map['product'],
      quantity: map['quantity'],
      price: map['price'],
      duration: map['duration'],
      status: map['status'],
    );
  }
}
