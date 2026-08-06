import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../models/appointment.dart";
import "../../services/appointment_service.dart";
import "../../services/patient_account_service.dart";
import "../../widgets/common_widgets.dart";
import "../../widgets/appointment_banner.dart";
import "../../widgets/avatar_picker.dart";
import "../welcome_auth_screen.dart";
import "patient_profile_edit_screen.dart";
import "prescription_history_screen.dart";
import "book_appointment_screen.dart";
import "message_doctor_list_screen.dart";

class PatientDashboard extends StatefulWidget {
  final String phoneNumber;
  const PatientDashboard({super.key, required this.phoneNumber});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _tab = 0;
  static const _titles = ["My Prescriptions", "My Appointments", "Messages"];
  late Future<List<Appointment>> _appointmentsFuture;
  String _name = "";
  int _avatarIndex = 0;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = AppointmentService().getForPatient(widget.phoneNumber);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await PatientAccountService().getProfile(widget.phoneNumber);
    if (profile != null && mounted) {
      setState(() {
        _name = profile["name"] ?? "";
        _avatarIndex = profile["avatarIndex"] ?? 0;
        _photoPath = profile["photoPath"];
      });
    }
  }

  Future<void> _openProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PatientProfileEditScreen(
          phoneNumber: widget.phoneNumber,
          currentName: _name,
          currentAvatarIndex: _avatarIndex,
          currentPhotoPath: _photoPath,
        ),
      ),
    );
    if (updated == true) _loadProfile();
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
      PatientPrescriptionHistoryScreen(phoneNumber: widget.phoneNumber),
      BookAppointmentScreen(phoneNumber: widget.phoneNumber),
      MessageDoctorListScreen(patientName: _name, patientPhone: widget.phoneNumber),
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
              const RoleBadge(role: "patient"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _openProfile,
              icon: AvatarCircle(index: _avatarIndex, photoPath: _photoPath, size: 30),
              tooltip: "Edit profile",
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              GreetingBanner(name: _name.isEmpty ? "there" : _name),
              AppointmentReminderBanner(future: _appointmentsFuture),
              Expanded(child: screens[_tab]),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: "Prescriptions"),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: "Appointments"),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), label: "Messages"),
          ],
        ),
      ),
    );
  }
}


