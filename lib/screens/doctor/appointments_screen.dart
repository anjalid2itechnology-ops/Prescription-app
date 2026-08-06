import "package:flutter/material.dart";
import "../../models/appointment.dart";
import "../../services/appointment_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class AppointmentsScreen extends StatefulWidget {
  final String doctorId;
  const AppointmentsScreen({super.key, required this.doctorId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> _future;
  final _service = AppointmentService();

  @override
  void initState() {
    super.initState();
    _future = _service.getForDoctor(widget.doctorId);
  }

  void _refresh() => setState(() => _future = _service.getForDoctor(widget.doctorId));

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Appointment>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoading();
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.event_available_outlined,
              message: "No appointments scheduled yet.",
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = list[i];
                final color = _statusColor(a.status);
                return FadeSlideIn(
                  index: i,
                  child: TapScale(
                    onTap: () {},
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
                          alignment: Alignment.center,
                          child: Icon(Icons.event_rounded, color: color, size: 20),
                        ),
                        title: Text("${a.date} · ${a.timeSlot}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                            child: Text(a.status.label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        trailing: PopupMenuButton<AppointmentStatus>(
                          onSelected: (status) async {
                            await _service.updateStatus(a, status);
                            _refresh();
                          },
                          itemBuilder: (_) => AppointmentStatus.values
                              .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                              .toList(),
                          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

