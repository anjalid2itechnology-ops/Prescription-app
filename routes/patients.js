const express = require("express");
const router = express.Router();
const Patient = require("../models/Patient");
const { verifyToken, requireRole } = require("../middleware/auth");

router.get("/", async (req, res) => {
  const filter = {};
  if (req.query.doctorId) filter.doctorAtSign = req.query.doctorId;
  const patients = await Patient.find(filter).sort({ name: 1 });
  res.json(patients);
});

router.post("/", verifyToken, requireRole("doctor"), async (req, res) => {
  try {
    const patient = new Patient(req.body);
    await patient.save();
    res.json(patient);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;

