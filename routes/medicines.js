const express = require("express");
const router = express.Router();
const Medicine = require("../models/Medicine");
const { verifyToken, requireRole } = require("../middleware/auth");

router.get("/", async (req, res) => {
  const list = await Medicine.find().sort({ name: 1 });
  res.json(list);
});

router.post("/", verifyToken, requireRole("pharmacist"), async (req, res) => {
  try {
    const medicine = new Medicine(req.body);
    await medicine.save();
    res.json(medicine);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put("/:id", verifyToken, requireRole("pharmacist"), async (req, res) => {
  try {
    const updated = await Medicine.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put("/:id/reduce-stock", async (req, res) => {
  try {
    const medicine = await Medicine.findById(req.params.id);
    if (medicine) {
      medicine.stockQuantity = Math.max(0, medicine.stockQuantity - (req.body.amount || 1));
      await medicine.save();
    }
    res.json(medicine);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
