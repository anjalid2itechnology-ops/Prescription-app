const express = require("express");
const router = express.Router();
const Account = require("../models/Account");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");

function hashPassword(password) {
  return crypto.createHash("sha256").update(password.trim()).digest("hex");
}

router.post("/register", async (req, res) => {
  try {
    const { name, email, password, role, specialty, avatarIndex, photoPath } = req.body;
    const atSign = "@" + email.split("@")[0];
    const account = new Account({
      name, email, role, specialty,
      passwordHash: hashPassword(password),
      atSign,
      avatarIndex: avatarIndex || 0,
      photoPath: photoPath || null,
    });
    await account.save();
    res.json(account);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password, role } = req.body;
    const account = await Account.findOne({ email: email.toLowerCase(), role });
    if (!account || account.passwordHash !== hashPassword(password)) {
      return res.status(401).json({ error: "Invalid email or password" });
    }
    const token = jwt.sign(
      { id: account._id, role: account.role, email: account.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );
    res.json({ ...account.toObject(), token });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get("/", async (req, res) => {
  const accounts = await Account.find().sort({ name: 1 });
  res.json(accounts);
});

router.put("/:id", async (req, res) => {
  try {
    const updated = await Account.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    const account = await Account.findOne({ email: email.toLowerCase() });
    if (!account) return res.status(404).json({ error: "Account not found" });
    account.passwordHash = hashPassword(newPassword);
    await account.save();
    res.json({ success: true });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;

