import "package:flutter/material.dart";
import "package:at_client_mobile/at_client_mobile.dart";

class AtSignTestScreen extends StatefulWidget {
  const AtSignTestScreen({super.key});

  @override
  State<AtSignTestScreen> createState() => _AtSignTestScreenState();
}

class _AtSignTestScreenState extends State<AtSignTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AtSign Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Just testing if OnboardingWidgetService is accessible
            final service = OnboardingWidgetService();
            debugPrint("Service found: $service");
          },
          child: const Text("Test AtSign SDK"),
        ),
      ),
    );
  }
}
