const mongoose = require("mongoose");

const accountSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ["doctor", "pharmacist"], required: true },
  specialty: { type: String, default: null },
  atSign: { type: String, required: true },
  avatarIndex: { type: Number, default: 0 },
  photoPath: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model("Account", accountSchema);
