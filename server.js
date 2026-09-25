require("dotenv").config();
const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

app.get("/", (req, res) => res.json({ status: "Prescription backend running" }));

app.use("/api/accounts", require("./routes/accounts"));
app.use("/api/patient-accounts", require("./routes/patientAccounts"));
app.use("/api/patients", require("./routes/patients"));
app.use("/api/prescriptions", require("./routes/prescriptions"));
app.use("/api/appointments", require("./routes/appointments"));
app.use("/api/medicines", require("./routes/medicines"));
app.use("/api/reports", require("./routes/reports"));
app.use("/api/atsign-check", require("./routes/atsignCheck"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));

