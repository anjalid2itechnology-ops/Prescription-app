import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'welcome_auth_screen.dart';

/// MANDATORY FIRST-RUN ATSIGN GATE.
/// Shown automatically whenever KeychainStorage().getAllAtsigns() is empty.
/// The user cannot reach any auth workflow or app UI until they tap
/// "Continue" here. See ATPLATFORM_GUIDELINES.md -> "Project Continuity".
class AtsignGateScreen extends StatelessWidget {
  const AtsignGateScreen({super.key});

  static const _starterPackUrl = 'https://my.atsign.com/starterpack_app';

  Future<void> _openStarterPack() async {
    final uri = Uri.parse(_starterPackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.alternate_email_rounded,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Using this app requires an Atsign.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'If you already have an Atsign, tap "Continue."\n\n'
                    'Or, get free, temporary Atsigns via the Starter Pack:',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Step(number: '1', text: 'Tap "Get My Starter Pack" below, or visit\nmy.atsign.com/starterpack_app in your browser.'),
                          SizedBox(height: 12),
                          _Step(number: '2', text: 'Enter your email address.'),
                          SizedBox(height: 12),
                          _Step(number: '3', text: 'Verify your email with a one-time passcode.'),
                          SizedBox(height: 12),
                          _Step(number: '4', text: 'Come back to the app and tap "Continue."'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _openStarterPack,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Get My Starter Pack'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const WelcomeAuthScreen()),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Text(number,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}
