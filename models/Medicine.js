const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema({
  name: { type: String, required: true },
  stockQuantity: { type: Number, default: 0 },
  unitPrice: { type: Number, default: 0 },
  expiryDate: { type: String, default: "" },
}, { timestamps: true });

module.exports = mongoose.model("Medicine", medicineSchema);
