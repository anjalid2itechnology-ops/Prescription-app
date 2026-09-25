const express = require("express");
const router = express.Router();
const Account = require("../models/Account");
const PatientAccount = require("../models/PatientAccount");
const Patient = require("../models/Patient");
const Prescription = require("../models/Prescription");
const Appointment = require("../models/Appointment");
const Medicine = require("../models/Medicine");

router.get("/summary", async (req, res) => {
  try {
    const [totalDoctors, totalPharmacists, totalPatientAccounts, totalPatientRecords] = await Promise.all([
      Account.countDocuments({ role: "doctor" }),
      Account.countDocuments({ role: "pharmacist" }),
      PatientAccount.countDocuments({}),
      Patient.countDocuments({}),
    ]);

    const [prescriptionsDispensed, prescriptionsPending] = await Promise.all([
      Prescription.countDocuments({ dispensed: true }),
      Prescription.countDocuments({ dispensed: false }),
    ]);

    const [apptConfirmed, apptCompleted, apptCancelled] = await Promise.all([
      Appointment.countDocuments({ status: "confirmed" }),
      Appointment.countDocuments({ status: "completed" }),
      Appointment.countDocuments({ status: "cancelled" }),
    ]);

    const lowStockMedicines = await Medicine.find({ stockQuantity: { $lt: 10 } })
      .sort({ stockQuantity: 1 })
      .select("name stockQuantity");

    res.json({
      staff: {
        doctors: totalDoctors,
        pharmacists: totalPharmacists,
        patients: totalPatientAccounts,
        patientRecords: totalPatientRecords,
      },
      prescriptions: {
        dispensed: prescriptionsDispensed,
        pending: prescriptionsPending,
        total: prescriptionsDispensed + prescriptionsPending,
      },
      appointments: {
        confirmed: apptConfirmed,
        completed: apptCompleted,
        cancelled: apptCancelled,
        total: apptConfirmed + apptCompleted + apptCancelled,
      },
      lowStockMedicines: lowStockMedicines.map(m => ({ name: m.name, stockQuantity: m.stockQuantity })),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
