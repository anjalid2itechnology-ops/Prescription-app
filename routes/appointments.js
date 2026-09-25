const express = require("express");
const router = express.Router();
const Appointment = require("../models/Appointment");
const { verifyToken, requireRole } = require("../middleware/auth");

router.post("/", verifyToken, requireRole("patient"), async (req, res) => {
  try {
    const appointment = new Appointment(req.body);
    await appointment.save();
    res.json(appointment);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get("/", async (req, res) => {
  const filter = {};
  if (req.query.doctorAtSign) filter.doctorAtSign = req.query.doctorAtSign;
  if (req.query.patientAtSign) filter.patientAtSign = req.query.patientAtSign;
  const list = await Appointment.find(filter).sort({ date: 1 });
  res.json(list);
});

router.put("/:id/status", verifyToken, requireRole("doctor"), async (req, res) => {
  try {
    const updated = await Appointment.findByIdAndUpdate(req.params.id, { status: req.body.status }, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;

