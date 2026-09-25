import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "../../models/report_summary.dart";
import "../../services/report_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<ReportSummary?> _future;

  @override
  void initState() {
    super.initState();
    _future = ReportService().getSummary();
  }

  void _refresh() => setState(() => _future = ReportService().getSummary());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReportSummary?>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        }
        final data = snapshot.data;
        if (data == null) {
          return const EmptyState(
            icon: Icons.bar_chart_rounded,
            message: "Could not load reports. Pull down to retry.",
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionHeader(title: "Overview"),
              Row(
                children: [
                  Expanded(child: StatCard(icon: Icons.medical_services_outlined, value: "${data.doctorsCount}", label: "Doctors", color: AppColors.doctorTag)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(icon: Icons.medication_outlined, value: "${data.pharmacistsCount}", label: "Pharmacists", color: AppColors.pharmacistTag)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: StatCard(icon: Icons.people_outline_rounded, value: "${data.patientsCount}", label: "Patients", color: AppColors.patientTag)),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(icon: Icons.folder_shared_outlined, value: "${data.patientRecordsCount}", label: "Patient records", color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 28),
              SectionHeader(title: "Appointments"),
              _AppointmentsPieCard(data: data),

              const SizedBox(height: 28),
              SectionHeader(title: "Prescriptions"),
              _PrescriptionsBarCard(data: data),

              const SizedBox(height: 28),
              SectionHeader(title: "Low stock medicines (< 10 units)"),
              if (data.lowStockMedicines.isEmpty)
                const EmptyState(icon: Icons.inventory_2_outlined, message: "All medicines are well stocked.")
              else
                ...data.lowStockMedicines.map((m) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        trailing: Text("${m.stockQuantity} left", style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ),
                    )),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _AppointmentsPieCard extends StatelessWidget {
  final ReportSummary data;
  const _AppointmentsPieCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.appointmentsConfirmed + data.appointmentsCompleted + data.appointmentsCancelled;
    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text("No appointments yet.", style: TextStyle(color: AppColors.textSecondary))),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 120, height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                  sections: [
                    PieChartSectionData(value: data.appointmentsConfirmed.toDouble(), color: AppColors.primary, title: "", radius: 22),
                    PieChartSectionData(value: data.appointmentsCompleted.toDouble(), color: AppColors.success, title: "", radius: 22),
                    PieChartSectionData(value: data.appointmentsCancelled.toDouble(), color: AppColors.danger, title: "", radius: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendRow(AppColors.primary, "Confirmed", data.appointmentsConfirmed),
                  const SizedBox(height: 10),
                  _legendRow(AppColors.success, "Completed", data.appointmentsCompleted),
                  const SizedBox(height: 10),
                  _legendRow(AppColors.danger, "Cancelled", data.appointmentsCancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text("$value", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _PrescriptionsBarCard extends StatelessWidget {
  final ReportSummary data;
  const _PrescriptionsBarCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = [data.prescriptionsDispensed, data.prescriptionsPending, 4]
        .reduce((a, b) => a > b ? a : b)
        .toDouble() * 1.25;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final label = value.toInt() == 0 ? "Dispensed" : "Pending";
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: data.prescriptionsDispensed.toDouble(), color: AppColors.success, width: 40, borderRadius: BorderRadius.circular(6)),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: data.prescriptionsPending.toDouble(), color: AppColors.warning, width: 40, borderRadius: BorderRadius.circular(6)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
