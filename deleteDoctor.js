require("dotenv").config();
const mongoose = require("mongoose");
const Account = require("./models/Account");

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log("Connected to MongoDB");

    const result = await Account.deleteMany({ role: "doctor" });
    console.log(`Deleted ${result.deletedCount} doctor account(s)`);

    mongoose.disconnect();
  })
  .catch((err) => {
    console.error("Error:", err);
  });