import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../theme/app_theme.dart";
import "welcome_landing_screen.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  _Slide(this.icon, this.title, this.desc, this.color);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = [
    _Slide(Icons.medical_services_rounded, "Doctor writes it", "Pulls up the patient, adds medicines and dosage, sends it straight into the queue.", AppColors.doctorTag),
    _Slide(Icons.medication_rounded, "Pharmacist dispenses it", "Sees the queue in order, checks stock against inventory, marks it fulfilled.", AppColors.pharmacistTag),
    _Slide(Icons.person_rounded, "Patient tracks it", "Opens their history any time — no calling the clinic to ask what was prescribed.", AppColors.patientTag),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomeLandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(onPressed: _finish, child: const Text("Skip")),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(color: s.color.withOpacity(0.14), borderRadius: BorderRadius.circular(28)),
                          alignment: Alignment.center,
                          child: Icon(s.icon, size: 44, color: s.color),
                        ),
                        const SizedBox(height: 34),
                        Text(s.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
                        const SizedBox(height: 12),
                        Text(s.desc, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page == _slides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
                    }
                  },
                  child: Text(_page == _slides.length - 1 ? "Get started" : "Next"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
