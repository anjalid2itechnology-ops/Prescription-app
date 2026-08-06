import "package:flutter/material.dart";
import "../theme/app_theme.dart";

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withOpacity(0.55);
    return FadeTransition(
      opacity: _c,
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 56),
          child: Column(
            children: [
              Icon(widget.icon, size: 44, color: secondary),
              const SizedBox(height: 14),
              Text(widget.message, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final color = RoleStyle.colorFor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(999)),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: SizedBox(
            width: 34, height: 34,
            child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
}

class DashboardScaffold extends StatelessWidget {
  final String title;
  final String role;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;

  const DashboardScaffold({
    super.key,
    required this.title,
    required this.role,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text(title), const SizedBox(width: 10), RoleBadge(role: role)]),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Wraps any widget with a subtle press-down scale + ripple — the
/// touchscreen equivalent of a "hover" effect on desktop.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  const TapScale({super.key, required this.child, this.onTap, this.borderRadius});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(18),
          child: InkWell(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(18),
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Staggers the entrance of list items — each one fades + slides in a
/// little after the previous, so lists feel alive when they load.
class FadeSlideIn extends StatefulWidget {
  final int index;
  final Widget child;
  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 40 * widget.index.clamp(0, 12)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Small stat card used on overview/dashboard headers.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const StatCard({super.key, required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}

/// Opens a smooth, rounded bottom sheet with a drag handle — used for
/// "tap a card to see full details" interactions across the app.
Future<T?> showNiceSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  );
}

class GreetingBanner extends StatelessWidget {
  final String name;
  const GreetingBanner({super.key, required this.name});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  IconData get _icon {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 19) return Icons.nightlight_round;
    if (hour < 17) return Icons.wb_sunny_rounded;
    return Icons.wb_twilight_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Icon(_icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$_greeting, $name",
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
