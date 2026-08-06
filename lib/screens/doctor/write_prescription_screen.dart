import "package:flutter/material.dart";
import "../../models/patient.dart";
import "../../models/prescription.dart";
import "../../services/patient_service.dart";
import "../../services/prescription_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class WritePrescriptionScreen extends StatefulWidget {
  final String doctorId;
  const WritePrescriptionScreen({super.key, required this.doctorId});

  @override
  State<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _MedRow {
  final name = TextEditingController();
  final dosage = TextEditingController();
  final frequency = TextEditingController();
  final duration = TextEditingController();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _pharmacistCtrl = TextEditingController(text: "@pharmacist");
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  final List<_MedRow> _meds = [_MedRow()];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    PatientService().getPatientsForDoctor(widget.doctorId).then((p) => setState(() => _patients = p));
  }

  Future<void> _submit() async {
    if (_selectedPatient == null || _diagnosisCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a patient and enter a diagnosis.")),
      );
      return;
    }
    setState(() => _busy = true);
    final lines = _meds
        .where((m) => m.name.text.trim().isNotEmpty)
        .map((m) => MedicineLine(
              name: m.name.text.trim(),
              dosage: m.dosage.text.trim(),
              frequency: m.frequency.text.trim(),
              duration: m.duration.text.trim(),
            ))
        .toList();

    final result = await PrescriptionService().createPrescription(
      doctorId: widget.doctorId,
      patientId: _selectedPatient!.id,
      patientAtSign: _selectedPatient!.phoneNumber,
      diagnosis: _diagnosisCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      medicines: lines,
      pharmacistAtSign: _pharmacistCtrl.text.trim(),
    );

    setState(() => _busy = false);
    if (mounted) {
      Navigator.pop(context, result != null);
    }
  }

  Widget _medRow(_MedRow row, int index) {
    return FadeSlideIn(
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  const Text("Medicine", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                ]),
                if (_meds.length > 1)
                  IconButton(
                    onPressed: () => setState(() => _meds.removeAt(index)),
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: row.name, decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.medication_outlined))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: row.dosage, decoration: const InputDecoration(labelText: "Dosage"))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: row.frequency, decoration: const InputDecoration(labelText: "Frequency"))),
            ]),
            const SizedBox(height: 10),
            TextField(controller: row.duration, decoration: const InputDecoration(labelText: "Duration")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New prescription")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FadeSlideIn(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Patient>(
                      value: _selectedPatient,
                      decoration: const InputDecoration(labelText: "Patient", prefixIcon: Icon(Icons.person_outline_rounded)),
                      items: _patients
                          .map((p) => DropdownMenuItem(value: p, child: Text("${p.name} · ${p.phoneNumber}")))
                          .toList(),
                      onChanged: (p) => setState(() => _selectedPatient = p),
                    ),
                    const SizedBox(height: 14),
                    TextField(controller: _diagnosisCtrl, decoration: const InputDecoration(labelText: "Diagnosis", prefixIcon: Icon(Icons.medical_information_outlined))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Notes (optional)"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: "Medicines",
              action: TextButton.icon(
                onPressed: () => setState(() => _meds.add(_MedRow())),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add"),
              ),
            ),
            ..._meds.asMap().entries.map((e) => _medRow(e.value, e.key)),
            const SizedBox(height: 8),
            TextField(
              controller: _pharmacistCtrl,
              decoration: const InputDecoration(labelText: "Pharmacist's Atsign to notify", prefixIcon: Icon(Icons.alternate_email_rounded)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _submit,
                icon: _busy ? null : const Icon(Icons.send_rounded, size: 18),
                label: _busy
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Send prescription"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

