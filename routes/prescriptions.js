const express = require("express");
const router = express.Router();
const Prescription = require("../models/Prescription");
const { verifyToken, requireRole } = require("../middleware/auth");

router.post("/", verifyToken, requireRole("doctor"), async (req, res) => {
  try {
    const prescription = new Prescription(req.body);
    await prescription.save();
    res.json(prescription);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get("/dispense-queue", async (req, res) => {
  const filter = { dispensed: false };
  if (req.query.pharmacistAtSign) filter.pharmacistAtSign = req.query.pharmacistAtSign;
  const list = await Prescription.find(filter).sort({ createdAt: -1 });
  res.json(list);
});

router.get("/", async (req, res) => {
  const filter = {};
  if (req.query.doctorId) filter.doctorAtSign = req.query.doctorId;
  if (req.query.patientAtSign) filter.patientAtSign = req.query.patientAtSign;
  const list = await Prescription.find(filter).sort({ createdAt: -1 });
  res.json(list);
});

router.put("/:id/dispense", verifyToken, requireRole("pharmacist"), async (req, res) => {
  try {
    const updated = await Prescription.findByIdAndUpdate(req.params.id, { dispensed: true, dispensedAt: new Date().toISOString() }, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;

