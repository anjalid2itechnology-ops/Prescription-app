import "package:flutter/material.dart";
import "../theme/app_theme.dart";
import "../widgets/common_widgets.dart";
import "role_router_screen.dart";

class WelcomeLandingScreen extends StatelessWidget {
  const WelcomeLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120, right: -100,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(isDark ? 0.22 : 0.14),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    index: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF14B8A6)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text("R", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
                        ),
                        const SizedBox(width: 12),
                        const Text("Rx/One", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FadeSlideIn(
                    index: 1,
                    child: Text(
                      "Prescriptions,\nmade simple.",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 38, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 2,
                    child: Text(
                      "One app for doctors, patients, and pharmacists to stay on the same page.",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 15.5, height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(index: 3, child: const _RxSlipPreview()),
                  const Spacer(),
                  FadeSlideIn(
                    index: 4,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 420),
                              pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const RoleRouterScreen()),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text("Get started", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RxSlipPreview extends StatelessWidget {
  const _RxSlipPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("℞", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
              Text("NO. 0417-A", style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 24),
          _line(context, "Rx", "Amoxicillin 500mg", "3× daily, after meals — 7 days"),
          _line(context, "Pt", "Meera Nair", "Follow-up in 10 days"),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String k, String v, String s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 30, child: Text(k, style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

