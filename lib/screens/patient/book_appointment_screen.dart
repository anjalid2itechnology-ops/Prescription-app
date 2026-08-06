import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../models/appointment.dart";
import "../../services/appointment_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class BookAppointmentScreen extends StatefulWidget {
  final String phoneNumber;
  const BookAppointmentScreen({super.key, required this.phoneNumber});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _service = AppointmentService();
  final _doctorCtrl = TextEditingController(text: "@doctor");
  DateTime? _date;
  String? _slot;
  bool _busy = false;
  late Future<List<Appointment>> _future;

  static const _slots = ["9:00 AM", "10:30 AM", "12:00 PM", "2:30 PM", "4:00 PM", "5:30 PM"];

  @override
  void initState() {
    super.initState();
    _future = _service.getForPatient(widget.phoneNumber);
  }

  void _refresh() => setState(() => _future = _service.getForPatient(widget.phoneNumber));

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

  Future<void> _bookSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Book an appointment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: _doctorCtrl,
                  decoration: const InputDecoration(labelText: "Doctor ID or Email", prefixIcon: Icon(Icons.medical_services_outlined)),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      initialDate: DateTime.now(),
                    );
                    if (picked != null) setSheetState(() => _date = picked);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(_date == null ? "Choose date" : DateFormat("EEE, MMM d").format(_date!)),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _slots.map((s) {
                    final selected = s == _slot;
                    return ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setSheetState(() => _slot = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            if (_date == null || _slot == null || _doctorCtrl.text.trim().isEmpty) return;
                            setSheetState(() => _busy = true);
                            await _service.bookAppointment(
                              patientId: widget.phoneNumber,
                              patientAtSign: widget.phoneNumber,
                              doctorAtSign: _doctorCtrl.text.trim(),
                              date: DateFormat("yyyy-MM-dd").format(_date!),
                              timeSlot: _slot!,
                            );
                            setSheetState(() => _busy = false);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _refresh();
                          },
                    child: const Text("Confirm booking"),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: "Upcoming appointments",
            action: FilledButton.tonalIcon(
              onPressed: _bookSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Book"),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const AppLoading();
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.calendar_month_outlined,
                    message: "No appointments booked yet.",
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = list[i];
                    final color = _statusColor(a.status);
                    return FadeSlideIn(
                      index: i,
                      child: Card(
                        child: ListTile(
                          leading: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
                            alignment: Alignment.center,
                            child: Icon(Icons.event_rounded, color: color, size: 20),
                          ),
                          title: Text("${a.date} · ${a.timeSlot}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Text("with ${a.doctorAtSign}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                                  child: Text(a.status.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


