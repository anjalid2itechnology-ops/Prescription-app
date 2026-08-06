class Medicine {
  final String id;
  final String name;
  int stockQuantity;
  double unitPrice;
  String expiryDate;
  String lastUpdated;

  Medicine({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.unitPrice,
    required this.expiryDate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "stockQuantity": stockQuantity,
        "unitPrice": unitPrice,
        "expiryDate": expiryDate,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json["_id"] ?? json["id"] ?? "",
        name: json["name"] ?? "",
        stockQuantity: json["stockQuantity"] ?? 0,
        unitPrice: (json["unitPrice"] as num?)?.toDouble() ?? 0.0,
        expiryDate: json["expiryDate"] ?? "",
        lastUpdated: json["lastUpdated"] ?? "",
      );
}
