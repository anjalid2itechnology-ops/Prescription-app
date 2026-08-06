import "dart:convert";
import "../models/medicine.dart";
import "../models/prescription.dart";
import "api_config.dart";
import "api_client.dart";

class InventoryService {
  Future<List<Medicine>> getInventory() async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/medicines");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Medicine.fromJson(j)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  Future<Medicine?> addMedicine({
    required String name,
    required int stockQuantity,
    required double unitPrice,
    required String expiryDate,
  }) async {
    try {
      final res = await ApiClient.post(
        "${ApiConfig.baseUrl}/medicines",
        body: {
          "name": name,
          "stockQuantity": stockQuantity,
          "unitPrice": unitPrice,
          "expiryDate": expiryDate,
        },
      );
      if (res.statusCode != 200) return null;
      return Medicine.fromJson(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateMedicine(Medicine medicine) async {
    try {
      final res = await ApiClient.put("${ApiConfig.baseUrl}/medicines/${medicine.id}", body: medicine.toJson());
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> reduceStockForPrescription(Prescription prescription) async {
    final inventory = await getInventory();
    for (final line in prescription.medicines) {
      final match = inventory.where(
        (m) => m.name.toLowerCase().trim() == line.name.toLowerCase().trim(),
      );
      if (match.isNotEmpty) {
        final medicine = match.first;
        medicine.stockQuantity = (medicine.stockQuantity - 1).clamp(0, 1 << 31);
        await updateMedicine(medicine);
      }
    }
  }
}
