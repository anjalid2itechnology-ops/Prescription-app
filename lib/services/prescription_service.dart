import "dart:convert";
import "../models/prescription.dart";
import "api_config.dart";
import "api_client.dart";
import "at_service.dart";

class PrescriptionService {
  Future<Prescription?> createPrescription({
    required String doctorId,
    required String patientId,
    required String patientAtSign,
    required String diagnosis,
    required String notes,
    required List<MedicineLine> medicines,
    required String pharmacistAtSign,
  }) async {
    try {
      final res = await ApiClient.post(
        "${ApiConfig.baseUrl}/prescriptions",
        body: {
          "doctorAtSign": doctorId,
          "patientId": patientId,
          "patientAtSign": patientAtSign,
          "diagnosis": diagnosis,
          "notes": notes,
          "medicines": medicines.map((m) => m.toJson()).toList(),
          "pharmacistAtSign": pharmacistAtSign,
        },
      );
      if (res.statusCode != 200) return null;
      final prescription = Prescription.fromJson(jsonDecode(res.body));

      // Also store on AtSign network (encrypted, shared with patient + pharmacist)
      try {
        final atKey = "prescription.${prescription.id}";
        final atValue = prescription.toJson();

        await AtService.instance.putJson(
          key: atKey,
          value: atValue,
          sharedWithAtSign: patientAtSign,
        );

        await AtService.instance.notifyUpdate(
          key: atKey,
          value: atValue,
          toAtSign: patientAtSign,
        );

        if (pharmacistAtSign.isNotEmpty) {
          await AtService.instance.notifyUpdate(
            key: atKey,
            value: atValue,
            toAtSign: pharmacistAtSign,
          );
        }
      } catch (_) {
        // AtSign sync failed silently — MongoDB copy already saved, app still works
      }

      return prescription;
    } catch (_) {
      return null;
    }
  }

  Future<List<Prescription>> getHistoryForDoctor(String doctorId) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/prescriptions?doctorId=$doctorId");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Prescription.fromJson(j)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<List<Prescription>> getHistoryForPatient(String patientAtSign) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/prescriptions?patientAtSign=$patientAtSign");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Prescription.fromJson(j)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<List<Prescription>> getDispenseQueue(String pharmacistAtSign) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/prescriptions/dispense-queue?pharmacistAtSign=$pharmacistAtSign");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Prescription.fromJson(j)).where((p) => !p.dispensed).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<bool> markDispensed(Prescription prescription) async {
    try {
      final res = await ApiClient.put("${ApiConfig.baseUrl}/prescriptions/${prescription.id}/dispense", body: {});
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
