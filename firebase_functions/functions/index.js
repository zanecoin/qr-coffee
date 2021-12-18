const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");

const admin = require("firebase-admin");
admin.initializeApp();

const app = express();


app.post("/", async (req, res) => {
    var status;
    var extOrderId;
    iterateObject(req.body);

    function iterateObject(obj) {
        for (prop in obj) {
            if (typeof (obj[prop]) == "object") {
                iterateObject(obj[prop]);

            } else {
                if (prop == "extOrderId") {
                    extOrderId = obj[prop];
                }
                if (prop == "status") {
                    status = obj[prop];
                }
            }
        }
    }

    console.log(status);
    console.log(extOrderId);
    const order = await admin.firestore().collection("active_orders").doc(extOrderId);

    order.get().then((doc) => {
        if (doc.exists) {
            if (status == 'COMPLETED') {
                status = 'ACTIVE';
            }
            order.update({ 'status': status })
                .catch(err => {
                    console.log("Document does not exist.", err);
                })
        }
    }).catch(err => {
        console.log("Internal server error.", err);
    });

    res.status(200).send();
});

exports.gatewayNotification = functions.https.onRequest(app);

app.post("/", async (req, res) => {
    const message = req.body;

    await admin.firestore().collection('payu').add(message);

    res.status(200).send();
});

// exports.helloWorld = functions.https.onRequest((request, response) => {
//     response.send("Hello from Firebase!");
// });
