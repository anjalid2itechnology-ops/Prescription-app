import 'package:flutter/material.dart';
import '../../models/prescription.dart';
import '../../services/prescription_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PrescriptionHistoryScreen extends StatefulWidget {
  final String doctorId;
  const PrescriptionHistoryScreen({super.key, required this.doctorId});

  @override
  State<PrescriptionHistoryScreen> createState() => _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  late Future<List<Prescription>> _future;

  @override
  void initState() {
    super.initState();
    _future = PrescriptionService().getHistoryForDoctor(widget.doctorId);
  }

  void _refresh() => setState(() => _future = PrescriptionService().getHistoryForDoctor(widget.doctorId));

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
              message: 'No prescriptions written yet.\nTap "New prescription" to get started.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _PrescriptionCard(prescription: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(prescription.diagnosis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prescription.dispensed
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    prescription.dispensed ? 'Dispensed' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: prescription.dispensed ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...prescription.medicines.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'â€¢ ${m.name} â€” ${m.dosage}, ${m.frequency}, ${m.duration}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                )),
            if (prescription.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${prescription.notes}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

