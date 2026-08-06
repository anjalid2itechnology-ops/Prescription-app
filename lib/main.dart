import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:shared_preferences/shared_preferences.dart";
import "theme/app_theme.dart";
import "theme/theme_controller.dart";
import "theme/accent_controller.dart";
import "screens/onboarding_screen.dart";
import "screens/welcome_landing_screen.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ThemeController.load();
  await AccentController.load();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool("onboarding_done") ?? false;
  runApp(PrescriptionApp(onboardingDone: onboardingDone));
}

final navigatorKey = GlobalKey<NavigatorState>();

class PrescriptionApp extends StatelessWidget {
  final bool onboardingDone;
  const PrescriptionApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: AccentController.color,
          builder: (context, accent, __) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: "Prescription App",
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(accent),
              darkTheme: AppTheme.dark(accent),
              themeMode: mode,
              home: onboardingDone ? const WelcomeLandingScreen() : const OnboardingScreen(),
              builder: (context, child) => Stack(
                children: [
                  if (child != null) child,
                  const _FloatingControls(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FloatingControls extends StatelessWidget {
  const _FloatingControls();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 44,
      right: 12,
      child: SafeArea(
        child: Builder(
          builder: (navContext) => Row(
            children: [
              _ColorPickerButton(navContext: navContext),
              const SizedBox(width: 8),
              const _ThemeToggleButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final BuildContext navContext;
  const _ColorPickerButton({required this.navContext});

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose accent color", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: AccentController.presets.map((c) {
                return ValueListenableBuilder<Color>(
                  valueListenable: AccentController.color,
                  builder: (context, current, _) {
                    final selected = current.value == c.value;
                    return Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => AccentController.setColor(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: selected ? Colors.black.withOpacity(0.4) : Colors.transparent, width: 2.5),
                          ),
                          alignment: Alignment.center,
                          child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: AccentController.color,
      builder: (context, color, _) {
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              debugPrint("COLOR BUTTON TAPPED");
              final ctx = navigatorKey.currentContext;
              if (ctx != null) _showPicker(ctx);
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.palette_outlined, color: Colors.white, size: 17),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => ThemeController.toggle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF15201F) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF223330) : const Color(0xFFE1E9E7)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (c, a) => RotationTransition(turns: a, child: ScaleTransition(scale: a, child: c)),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: 20,
                  color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}








