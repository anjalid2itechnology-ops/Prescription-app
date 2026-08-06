import "package:flutter/material.dart";
import "../../models/user_account.dart";
import "../../services/account_service.dart";
import "../../services/chat_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";
import "../../widgets/avatar_picker.dart";
import "../chat_screen.dart";

class MessageDoctorListScreen extends StatefulWidget {
  final String patientName;
  final String patientPhone;
  const MessageDoctorListScreen({super.key, required this.patientName, required this.patientPhone});

  @override
  State<MessageDoctorListScreen> createState() => _MessageDoctorListScreenState();
}

class _MessageDoctorListScreenState extends State<MessageDoctorListScreen> {
  late Future<List<UserAccount>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDoctors();
  }

  Future<List<UserAccount>> _loadDoctors() async {
    final all = await AccountService().getAllAccounts();
    return AccountService().doctorsOnly(all);
  }

  void _openChat(UserAccount doctor) {
    final threadId = ChatService().threadId(doctor.email, widget.patientPhone);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        threadId: threadId,
        myName: widget.patientName,
        myRole: "patient",
        otherPartyName: "Dr. ${doctor.name}",
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<UserAccount>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoading();
          final doctors = snapshot.data!;
          if (doctors.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              message: "No doctors available to message yet.",
            );
          }
          return ListView.separated(
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = doctors[i];
              return TapScale(
                onTap: () => _openChat(d),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: AvatarCircle(index: d.avatarIndex, photoPath: d.photoPath),
                    title: Text("Dr. ${d.name}", style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(d.specialty ?? "General"),
                    trailing: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
