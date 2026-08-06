import "package:flutter/material.dart";
import "../models/appointment.dart";
import "../theme/app_theme.dart";

class AppointmentReminderBanner extends StatelessWidget {
  final Future<List<Appointment>> future;
  const AppointmentReminderBanner({super.key, required this.future});

  String _today() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, "0")}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Appointment>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final today = _today();
        final todays = snapshot.data!
            .where((a) => a.date == today && a.status == AppointmentStatus.confirmed)
            .toList();
        if (todays.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  todays.length == 1
                      ? "You have 1 appointment today at ${todays.first.timeSlot}"
                      : "You have ${todays.length} appointments today",
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
