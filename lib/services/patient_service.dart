import "dart:convert";
import "../models/patient.dart";
import "api_config.dart";
import "api_client.dart";

class PatientService {
  Future<Patient?> addPatient({
    required String doctorId,
    required String name,
    required String phoneNumber,
    required int age,
    required String gender,
  }) async {
    try {
      final res = await ApiClient.post(
        "${ApiConfig.baseUrl}/patients",
        body: {
          "name": name,
          "phoneNumber": phoneNumber,
          "age": age,
          "gender": gender,
          "doctorAtSign": doctorId,
        },
      );
      if (res.statusCode != 200) return null;
      return Patient.fromJson(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }

  Future<List<Patient>> getPatientsForDoctor(String doctorId) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/patients?doctorId=$doctorId");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Patient.fromJson(j)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }
}
