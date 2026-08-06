enum AppointmentStatus { confirmed, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.confirmed:
        return "Confirmed";
      case AppointmentStatus.completed:
        return "Completed";
      case AppointmentStatus.cancelled:
        return "Cancelled";
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String patientAtSign;
  final String doctorAtSign;
  final String date;
  final String timeSlot;
  AppointmentStatus status;
  final String createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientAtSign,
    required this.doctorAtSign,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.confirmed,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "patientId": patientId,
        "patientAtSign": patientAtSign,
        "doctorAtSign": doctorAtSign,
        "date": date,
        "timeSlot": timeSlot,
        "status": status.name,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json["_id"] ?? json["id"] ?? "",
        patientId: json["patientId"] ?? "",
        patientAtSign: json["patientAtSign"] ?? "",
        doctorAtSign: json["doctorAtSign"] ?? "",
        date: json["date"] ?? "",
        timeSlot: json["timeSlot"] ?? "",
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == json["status"],
          orElse: () => AppointmentStatus.confirmed,
        ),
        createdAt: json["createdAt"] ?? "",
      );
}
