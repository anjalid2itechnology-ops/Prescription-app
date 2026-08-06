class MedicineLine {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  MedicineLine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "dosage": dosage,
        "frequency": frequency,
        "duration": duration,
      };

  factory MedicineLine.fromJson(Map<String, dynamic> json) => MedicineLine(
        name: json["name"] ?? "",
        dosage: json["dosage"] ?? "",
        frequency: json["frequency"] ?? "",
        duration: json["duration"] ?? "",
      );
}

class Prescription {
  final String id;
  final String patientId;
  final String patientAtSign;
  final String doctorAtSign;
  final String diagnosis;
  final String notes;
  final List<MedicineLine> medicines;
  bool dispensed;
  String? dispensedAt;
  final String createdAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientAtSign,
    required this.doctorAtSign,
    required this.diagnosis,
    required this.notes,
    required this.medicines,
    this.dispensed = false,
    this.dispensedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "patientId": patientId,
        "patientAtSign": patientAtSign,
        "doctorAtSign": doctorAtSign,
        "diagnosis": diagnosis,
        "notes": notes,
        "medicines": medicines.map((m) => m.toJson()).toList(),
        "dispensed": dispensed,
        "dispensedAt": dispensedAt,
      };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json["_id"] ?? json["id"] ?? "",
        patientId: json["patientId"] ?? "",
        patientAtSign: json["patientAtSign"] ?? "",
        doctorAtSign: json["doctorAtSign"] ?? "",
        diagnosis: json["diagnosis"] ?? "",
        notes: json["notes"] ?? "",
        medicines: (json["medicines"] as List? ?? [])
            .map((m) => MedicineLine.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
        dispensed: json["dispensed"] ?? false,
        dispensedAt: json["dispensedAt"],
        createdAt: json["createdAt"] ?? "",
      );
}
