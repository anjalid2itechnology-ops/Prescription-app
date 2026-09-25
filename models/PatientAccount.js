const mongoose = require("mongoose");

const patientAccountSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  avatarIndex: { type: Number, default: 0 },
  photoPath: { type: String, default: null },
  atSign: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model("PatientAccount", patientAccountSchema);
