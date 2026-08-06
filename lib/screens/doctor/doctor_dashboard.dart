import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../models/appointment.dart";
import "../../models/user_account.dart";
import "../../services/appointment_service.dart";
import "../../widgets/common_widgets.dart";
import "../../widgets/appointment_banner.dart";
import "../../widgets/avatar_picker.dart";
import "../profile_edit_screen.dart";
import "../welcome_auth_screen.dart";
import "patients_screen.dart";
import "write_prescription_screen.dart";
import "appointments_screen.dart";
import "prescription_history_screen.dart";

class DoctorDashboard extends StatefulWidget {
  final UserAccount account;
  const DoctorDashboard({super.key, required this.account});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _tab = 0;
  late UserAccount _account;
  late Future<List<Appointment>> _appointmentsFuture;

  static const _titles = ["Patients", "Prescription History", "Appointments"];

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _appointmentsFuture = AppointmentService().getForDoctor(_account.id);
  }

  Future<void> _openProfile() async {
    final updated = await Navigator.of(context).push<UserAccount>(
      MaterialPageRoute(builder: (_) => ProfileEditScreen(account: _account)),
    );
    if (updated != null) setState(() => _account = updated);
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Exit app?"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Exit")),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PatientsScreen(doctorAccount: _account),
      PrescriptionHistoryScreen(doctorId: _account.id),
      AppointmentsScreen(doctorId: _account.id),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmExit()) {
          if (context.mounted) SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(_titles[_tab]),
              const SizedBox(width: 10),
              const RoleBadge(role: "doctor"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _openProfile,
              icon: AvatarCircle(index: _account.avatarIndex, photoPath: _account.photoPath, size: 30),
              tooltip: "Edit profile",
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              GreetingBanner(name: "Dr. ${_account.name}"),
              AppointmentReminderBanner(future: _appointmentsFuture),
              Expanded(child: screens[_tab]),
            ],
          ),
        ),
        floatingActionButton: _tab != 1
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => WritePrescriptionScreen(doctorId: _account.id)),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text("New prescription"),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.people_outline_rounded), label: "Patients"),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: "Prescriptions"),
            NavigationDestination(icon: Icon(Icons.event_available_outlined), label: "Appointments"),
          ],
        ),
      ),
    );
  }
}


