class ReportSummary {
  final int doctorsCount;
  final int pharmacistsCount;
  final int patientsCount;
  final int patientRecordsCount;
  final int prescriptionsDispensed;
  final int prescriptionsPending;
  final int appointmentsConfirmed;
  final int appointmentsCompleted;
  final int appointmentsCancelled;
  final List<LowStockItem> lowStockMedicines;

  ReportSummary({
    required this.doctorsCount,
    required this.pharmacistsCount,
    required this.patientsCount,
    required this.patientRecordsCount,
    required this.prescriptionsDispensed,
    required this.prescriptionsPending,
    required this.appointmentsConfirmed,
    required this.appointmentsCompleted,
    required this.appointmentsCancelled,
    required this.lowStockMedicines,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        doctorsCount: json["staff"]?["doctors"] ?? 0,
        pharmacistsCount: json["staff"]?["pharmacists"] ?? 0,
        patientsCount: json["staff"]?["patients"] ?? 0,
        patientRecordsCount: json["staff"]?["patientRecords"] ?? 0,
        prescriptionsDispensed: json["prescriptions"]?["dispensed"] ?? 0,
        prescriptionsPending: json["prescriptions"]?["pending"] ?? 0,
        appointmentsConfirmed: json["appointments"]?["confirmed"] ?? 0,
        appointmentsCompleted: json["appointments"]?["completed"] ?? 0,
        appointmentsCancelled: json["appointments"]?["cancelled"] ?? 0,
        lowStockMedicines: (json["lowStockMedicines"] as List? ?? [])
            .map((m) => LowStockItem(name: m["name"] ?? "", stockQuantity: m["stockQuantity"] ?? 0))
            .toList(),
      );
}

class LowStockItem {
  final String name;
  final int stockQuantity;
  LowStockItem({required this.name, required this.stockQuantity});
}
