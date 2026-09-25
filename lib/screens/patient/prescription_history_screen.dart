import "package:flutter/material.dart";
import "../../models/prescription.dart";
import "../../models/user_account.dart";
import "../../services/account_service.dart";
import "../../services/appointment_service.dart";
import "../../services/prescription_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class PatientPrescriptionHistoryScreen extends StatefulWidget {
  final String phoneNumber;
  const PatientPrescriptionHistoryScreen({super.key, required this.phoneNumber});

  @override
  State<PatientPrescriptionHistoryScreen> createState() => _PatientPrescriptionHistoryScreenState();
}

class _PatientPrescriptionHistoryScreenState extends State<PatientPrescriptionHistoryScreen> {
  late Future<List<Prescription>> _future;
  late Future<Map<String, String>> _doctorNamesFuture;
  final Set<String> _requested = {};

  @override
  void initState() {
    super.initState();
    _future = PrescriptionService().getHistoryForPatient(widget.phoneNumber);
    _doctorNamesFuture = _loadDoctorNames();
  }

  Future<Map<String, String>> _loadDoctorNames() async {
    final all = await AccountService().getAllAccounts();
    final doctors = AccountService().doctorsOnly(all);
    return {for (final d in doctors) d.id: d.name};
  }

  String _today() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, "0")}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
  }

  Future<void> _requestRefill(Prescription p) async {
    setState(() => _requested.add(p.id));
    await AppointmentService().bookAppointment(
      patientId: p.patientId,
      patientAtSign: widget.phoneNumber,
      doctorAtSign: p.doctorAtSign,
      date: _today(),
      timeSlot: "Refill request \u2014 ${p.diagnosis}",
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Refill request sent to your doctor.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Prescription>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoading();
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: "No prescriptions yet.\nYour doctor will send them here after your visit.",
            );
          }
          return FutureBuilder<Map<String, String>>(
            future: _doctorNamesFuture,
            builder: (context, doctorSnap) {
              final doctorNames = doctorSnap.data ?? {};
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];
                  final requested = _requested.contains(p.id);
                  final doctorName = doctorNames[p.doctorAtSign] ?? "your doctor";
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.diagnosis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text("Prescribed by Dr. $doctorName",
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 10),
                          ...p.medicines.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text("\u2022 ${m.name} \u2014 ${m.dosage}, ${m.frequency}, ${m.duration}",
                                    style: const TextStyle(fontSize: 13)),
                              )),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: requested ? null : () => _requestRefill(p),
                              icon: Icon(requested ? Icons.check_rounded : Icons.refresh_rounded, size: 16),
                              label: Text(requested ? "Request sent" : "Request refill"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
