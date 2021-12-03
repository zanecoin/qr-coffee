const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");

const admin = require("firebase-admin");
admin.initializeApp();

const app = express();

app.post("/", async (req, res) => {
    const message = req.body.status;

    await admin.firestore().collection("payu").add(message);

    res.status(200).send();
});
