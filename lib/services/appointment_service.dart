import "dart:convert";
import "../models/appointment.dart";
import "api_config.dart";
import "api_client.dart";
import "at_service.dart";

class AppointmentService {
  Future<Appointment?> bookAppointment({
    required String patientAtSign,
    required String patientId,
    required String doctorAtSign,
    required String date,
    required String timeSlot,
  }) async {
    try {
      final res = await ApiClient.post(
        "${ApiConfig.baseUrl}/appointments",
        body: {
          "patientId": patientId,
          "patientAtSign": patientAtSign,
          "doctorAtSign": doctorAtSign,
          "date": date,
          "timeSlot": timeSlot,
        },
      );
      if (res.statusCode != 200) return null;
      final appointment = Appointment.fromJson(jsonDecode(res.body));
      try {
        final atKey = "appointment.${appointment.id}";
        final atValue = {
          "patientAtSign": patientAtSign,
          "doctorAtSign": doctorAtSign,
          "date": date,
          "timeSlot": timeSlot,
        };
        await AtService.instance.putJson(key: atKey, value: atValue, sharedWithAtSign: doctorAtSign);
        await AtService.instance.notifyUpdate(key: atKey, value: atValue, toAtSign: doctorAtSign);
      } catch (_) {}
      return appointment;
    } catch (_) {
      return null;
    }
  }

  Future<List<Appointment>> getForPatient(String patientAtSign) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/appointments?patientAtSign=$patientAtSign");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Appointment.fromJson(j)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return [];
    }
  }

  Future<List<Appointment>> getForDoctor(String doctorAtSign) async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/appointments?doctorAtSign=$doctorAtSign");
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => Appointment.fromJson(j)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateStatus(Appointment appointment, AppointmentStatus status) async {
    try {
      final res = await ApiClient.put(
        "${ApiConfig.baseUrl}/appointments/${appointment.id}/status",
        body: {"status": status.name},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
