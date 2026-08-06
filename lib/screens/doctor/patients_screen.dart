import "package:flutter/material.dart";
import "../../models/patient.dart";
import "../../models/user_account.dart";
import "../../services/chat_service.dart";
import "../../services/patient_service.dart";
import "../../services/recently_viewed_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";
import "../chat_screen.dart";

class PatientsScreen extends StatefulWidget {
  final UserAccount doctorAccount;
  const PatientsScreen({super.key, required this.doctorAccount});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _service = PatientService();
  final _recent = RecentlyViewedService();
  late Future<List<Patient>> _future;
  late Future<List<RecentlyViewedPatient>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _future = _service.getPatientsForDoctor(widget.doctorAccount.id);
    _recentFuture = _recent.getAll();
  }

  void _refresh() => setState(() {
        _future = _service.getPatientsForDoctor(widget.doctorAccount.id);
        _recentFuture = _recent.getAll();
      });

  void _openChat(Patient p) {
    final threadId = ChatService().threadId(widget.doctorAccount.email, p.phoneNumber);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        threadId: threadId,
        myName: widget.doctorAccount.name,
        myRole: "doctor",
        otherPartyName: p.name,
      ),
    ));
  }

  Future<void> _openPatient(Patient p) async {
    await _recent.record(RecentlyViewedPatient(id: p.id, name: p.name, phone: p.phoneNumber));
    setState(() => _recentFuture = _recent.getAll());
    if (!mounted) return;
    showNiceSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryLight,
              child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : "?",
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text("${p.age} yrs · ${p.gender}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _row(Icons.phone_outlined, "Phone", p.phoneNumber),
          _row(Icons.event_outlined, "Registered", p.createdAt.split("T").first),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(context); _openChat(p); },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text("Message patient"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _showAddPatientSheet() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String gender = "Female";

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
                const Text("Add patient", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full name")),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone number"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Age"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(labelText: "Gender"),
                        items: ["Female", "Male", "Other"]
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => gender = v ?? gender),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
                    await _service.addPatient(
                      doctorId: widget.doctorAccount.id,
                      name: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      age: int.tryParse(ageCtrl.text.trim()) ?? 0,
                      gender: gender,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refresh();
                  },
                  child: const Text("Save patient"),
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
            title: "Your patients",
            action: FilledButton.tonalIcon(
              onPressed: _showAddPatientSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Add"),
            ),
          ),
          FutureBuilder<List<RecentlyViewedPatient>>(
            future: _recentFuture,
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recently viewed", style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: snap.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final r = snap.data![i];
                        return Chip(
                          label: Text(r.name, style: const TextStyle(fontSize: 12)),
                          avatar: const Icon(Icons.history_rounded, size: 14),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Patient>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const AppLoading();
                final patients = snapshot.data!;
                if (patients.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline_rounded,
                    message: "No patients yet. Tap \"Add\" to register one.",
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = patients[i];
                      return TapScale(
                        onTap: () => _openPatient(p),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : "?",
                                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("${p.age} yrs · ${p.gender} · ${p.phoneNumber}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary),
                              onPressed: () => _openChat(p),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

