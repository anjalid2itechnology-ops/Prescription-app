const express = require("express");
const router = express.Router();
const PatientAccount = require("../models/PatientAccount");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");

function hashPassword(password) {
  return crypto.createHash("sha256").update(password.trim()).digest("hex");
}

router.post("/register", async (req, res) => {
  try {
    const { name, phone, password, avatarIndex } = req.body;
    const existing = await PatientAccount.findOne({ phone });
    if (existing) return res.status(400).json({ error: "Phone number already registered" });
    const account = new PatientAccount({
      name, phone,
      passwordHash: hashPassword(password),
      avatarIndex: avatarIndex || 0,
    });
    await account.save();
    res.json(account);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { phone, password } = req.body;
    const account = await PatientAccount.findOne({ phone });
    if (!account || account.passwordHash !== hashPassword(password)) {
      return res.status(401).json({ error: "Invalid phone or password" });
    }
    const token = jwt.sign(
      { id: account._id, role: "patient", phone: account.phone },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );
    res.json({ ...account.toObject(), token });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get("/:phone", async (req, res) => {
  const account = await PatientAccount.findOne({ phone: req.params.phone });
  if (!account) return res.status(404).json({ error: "Not found" });
  res.json(account);
});

router.put("/:phone", async (req, res) => {
  try {
    const updated = await PatientAccount.findOneAndUpdate({ phone: req.params.phone }, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { phone, newPassword } = req.body;
    const account = await PatientAccount.findOne({ phone });
    if (!account) return res.status(404).json({ error: "Account not found" });
    account.passwordHash = hashPassword(newPassword);
    await account.save();
    res.json({ success: true });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;

