const mongoose = require("mongoose");
const medicineLineSchema = new mongoose.Schema({
  name: String,
  dosage: String,
  frequency: String,
  duration: String,
}, { _id: false });
const prescriptionSchema = new mongoose.Schema({
  patientId: { type: String, required: true },
  patientAtSign: { type: String, required: true },
  doctorAtSign: { type: String, required: true },
  pharmacistAtSign: { type: String, default: "" },
  diagnosis: { type: String, required: true },
  notes: { type: String, default: "" },
  medicines: [medicineLineSchema],
  dispensed: { type: Boolean, default: false },
  dispensedAt: { type: String, default: null },
}, { timestamps: true });
module.exports = mongoose.model("Prescription", prescriptionSchema);
