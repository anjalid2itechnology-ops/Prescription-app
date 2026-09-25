const express = require("express");
const router = express.Router();
const Account = require("../models/Account");
const PatientAccount = require("../models/PatientAccount");

router.get("/:atsign", async (req, res) => {
  try {
    const atSign = req.params.atsign;

    const staffAccount = await Account.findOne({ atSign });
    if (staffAccount) {
      return res.json({ taken: true, role: staffAccount.role, account: staffAccount });
    }

    const patientAccount = await PatientAccount.findOne({ atSign });
    if (patientAccount) {
      return res.json({ taken: true, role: "patient", account: patientAccount, phone: patientAccount.phone });
    }

    return res.json({ taken: false, role: null });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;