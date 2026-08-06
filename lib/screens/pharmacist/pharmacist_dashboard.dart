import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../models/user_account.dart";
import "../../widgets/common_widgets.dart";
import "../../widgets/avatar_picker.dart";
import "../profile_edit_screen.dart";
import "../welcome_auth_screen.dart";
import "dispense_queue_screen.dart";
import "inventory_screen.dart";

class PharmacistDashboard extends StatefulWidget {
  final UserAccount account;
  const PharmacistDashboard({super.key, required this.account});

  @override
  State<PharmacistDashboard> createState() => _PharmacistDashboardState();
}

class _PharmacistDashboardState extends State<PharmacistDashboard> {
  int _tab = 0;
  late UserAccount _account;
  static const _titles = ["Dispense Queue", "Inventory"];

  @override
  void initState() {
    super.initState();
    _account = widget.account;
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
      DispenseQueueScreen(pharmacistAtSign: _account.id),
      const InventoryScreen(),
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
              const RoleBadge(role: "pharmacist"),
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
              GreetingBanner(name: _account.name),
              Expanded(child: screens[_tab]),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.queue_outlined), label: "Queue"),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: "Inventory"),
          ],
        ),
      ),
    );
  }
}


