import "package:flutter/material.dart";
import "../../models/user_account.dart";
import "../../services/account_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";
import "../../widgets/avatar_picker.dart";
import "../welcome_auth_screen.dart";
import "create_account_screen.dart";

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _service = AccountService();
  late Future<List<UserAccount>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllAccounts();
  }

  void _refresh() => setState(() => _future = _service.getAllAccounts());

  void _openStaffDetails(UserAccount account) {
    final isDoctor = account.role == StaffRole.doctor;
    final color = isDoctor ? AppColors.doctorTag : AppColors.pharmacistTag;
    showNiceSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(index: account.avatarIndex, photoPath: account.photoPath, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(isDoctor ? "Doctor" : "Pharmacist", style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _detailRow(Icons.email_outlined, "Email", account.email),
          if (isDoctor) _detailRow(Icons.medical_information_outlined, "Specialty", account.specialty ?? "General"),
          _detailRow(Icons.alternate_email_rounded, "Assigned Atsign", account.atSign),
          _detailRow(Icons.event_outlined, "Created", account.createdAt.split("T").first),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text("Clinic Staff"),
          const SizedBox(width: 10),
          const RoleBadge(role: "admin"),
        ]),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<UserAccount>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const AppLoading();
            final all = snapshot.data!;
            final doctors = _service.doctorsOnly(all);
            final pharmacists = _service.pharmacistsOnly(all);
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: StatCard(icon: Icons.medical_services_outlined, value: "${doctors.length}", label: "Doctors", color: AppColors.doctorTag)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.medication_outlined, value: "${pharmacists.length}", label: "Pharmacists", color: AppColors.pharmacistTag)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.groups_outlined, value: "${all.length}", label: "Total staff", color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SectionHeader(title: "Doctors (${doctors.length})"),
                  if (doctors.isEmpty)
                    const EmptyState(icon: Icons.medical_services_outlined, message: "No doctors yet.")
                  else
                    ...doctors.asMap().entries.map((e) => FadeSlideIn(
                          index: e.key,
                          child: _StaffTile(account: e.value, onTap: () => _openStaffDetails(e.value)),
                        )),
                  const SizedBox(height: 24),
                  SectionHeader(title: "Pharmacists (${pharmacists.length})"),
                  if (pharmacists.isEmpty)
                    const EmptyState(icon: Icons.medication_outlined, message: "No pharmacists yet.")
                  else
                    ...pharmacists.asMap().entries.map((e) => FadeSlideIn(
                          index: e.key,
                          child: _StaffTile(account: e.value, onTap: () => _openStaffDetails(e.value)),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
          );
          if (created == true) _refresh();
        },
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text("New account"),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final UserAccount account;
  final VoidCallback onTap;
  const _StaffTile({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDoctor = account.role == StaffRole.doctor;
    final color = isDoctor ? AppColors.doctorTag : AppColors.pharmacistTag;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TapScale(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: AvatarCircle(index: account.avatarIndex, photoPath: account.photoPath),
            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(isDoctor ? "${account.specialty ?? "General"} · ${account.email}" : account.email),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

