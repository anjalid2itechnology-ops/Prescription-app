const mongoose = require("mongoose");
const appointmentSchema = new mongoose.Schema({
  patientId: { type: String, required: true },
  patientAtSign: { type: String, default: "" },
  doctorAtSign: { type: String, required: true },
  date: { type: String, required: true },
  timeSlot: { type: String, required: true },
  status: { type: String, enum: ["confirmed", "completed", "cancelled"], default: "confirmed" },
}, { timestamps: true });
module.exports = mongoose.model("Appointment", appointmentSchema);
