const mongoose = require("mongoose");

const patientSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  age: { type: Number, default: 0 },
  gender: { type: String, default: "" },
  doctorAtSign: { type: String, default: "" },
}, { timestamps: true });

module.exports = mongoose.model("Patient", patientSchema);
