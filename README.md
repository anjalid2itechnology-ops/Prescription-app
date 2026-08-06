# Prescription App

A clinic prescription-management app for four roles — **Doctor, Patient,
Pharmacist, Admin** — built on the [Atsign Platform](https://docs.atsign.com/core).
There is no application backend: every record is stored as an encrypted
`AtKey` on each user's own atServer and synced/shared peer-to-peer.

For generic Atsign Platform SDK patterns (initialization, communication
patterns, key construction, error handling), see **ATPLATFORM_GUIDELINES.md**
— that file is the SDK reference and should not be duplicated here.

## Roles & Permissions

| Role | Login | Can do |
|---|---|---|
| **Doctor** | Atsign + email/password | Add/manage patients, write prescriptions, view full prescription history for their patients, book/manage appointments |
| **Patient** | Atsign + phone number | View own prescription history (read-only), view/book own appointments |
| **Pharmacist** | Atsign + email/password | Receive new-prescription notifications, view dispense queue, mark prescriptions dispensed (auto-reduces stock), manage medicine inventory |
| **Admin** | Atsign + admin password | Create Doctor/Pharmacist accounts, view staff directory. No access to patient data, prescriptions, or inventory |

## Namespace
All application data lives under the `prescriptionapp` namespace, isolating
it from any other app sharing the same Atsign.

## Data Model → Key Table

| Entity | Key pattern | Owner (`sharedBy`) | Shared with |
|---|---|---|---|
| Patient | `patient.<id>` | Doctor's Atsign | — (doctor-only) |
| Prescription | `prescription.<id>` | Doctor's Atsign | Patient's Atsign (read-only copy) |
| Dispense queue entry | `dispense_queue.<id>` | Pharmacist's Atsign | — (written via notify from doctor) |
| Appointment | `appointment.<id>` | Patient's Atsign | Doctor's Atsign |
| Medicine (inventory) | `medicine.<id>` | Pharmacist's Atsign | — (pharmacist-only) |
| Staff account record | `account.<id>` | Admin's Atsign | — (admin-only directory) |

## Data Flow

1. **Doctor writes a prescription** → `PrescriptionService.createPrescription()`
   - Stores the record under the doctor's own Atsign (source of truth).
   - Shares a read-only copy directly with the patient's Atsign (sync communication).
   - Sends a **delivery-confirmed notification** to the pharmacist under
     `dispense_queue.<id>` so it shows up in their queue in near real time.
2. **Pharmacist dispenses** → `PrescriptionService.markDispensed()` flips
   `dispensed = true` and `InventoryService.reduceStockForPrescription()`
   decrements matching medicine stock by name.
3. **Patient books an appointment** → `AppointmentService.bookAppointment()`
   writes under the patient's Atsign and shares + notifies the doctor.
4. **Admin creates a Doctor/Pharmacist account** → `AccountService.createAccount()`
   records the name/email/password-hash/specialty and the **Atsign assigned**
   to that staff member. (Provisioning the physical Atsign itself uses the
   Registrar/APKAM onboarding flow described in ATPLATFORM_GUIDELINES.md —
   the admin assigns it here after it's been created.)

## Prescription JSON shape
```json
{
  "id": "uuid",
  "patientId": "uuid",
  "patientAtSign": "@patientAtsign",
  "doctorAtSign": "@doctorAtsign",
  "diagnosis": "string",
  "notes": "string",
  "medicines": [
    { "name": "string", "dosage": "string", "frequency": "string", "duration": "string" }
  ],
  "dispensed": false,
  "dispensedAt": null,
  "createdAt": "ISO-8601"
}
```

## Screens
- `AtsignGateScreen` — mandatory first-run gate (blocks app access until an Atsign exists on-device).
- `WelcomeAuthScreen` — all 4 required Atsign auth workflows (Keychain / Onboard / APKAM / .atKeys file).
- `RoleRouterScreen` — post-Atsign-auth role selection + role-specific credential (email/password or phone).
- `DoctorDashboard` — Patients / Prescriptions / Appointments tabs.
- `PatientDashboard` — read-only Prescriptions tab + Appointments (book/view) tab.
- `PharmacistDashboard` — Dispense Queue / Inventory tabs.
- `AdminDashboard` — staff directory + create-account flow.

## Getting Started
See the setup guide provided alongside this project for installing Flutter
and the Atsign SDK toolchain, then:

```bash
flutter pub get
flutter run
```

You will need at least one [free Atsign](https://my.atsign.com/starterpack_app)
to sign in during development.
