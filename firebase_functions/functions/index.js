const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");

const admin = require("firebase-admin");
admin.initializeApp();

const app = express();


app.post("/", async (req, res) => {
    var status;
    var extorderID;
    iterateObject(req.body);

    function iterateObject(obj) {
        for (prop in obj) {
            if (typeof (obj[prop]) == "object") {
                iterateObject(obj[prop]);

            } else {
                if (prop == "extorderID") {
                    extorderID = obj[prop];
                }
                if (prop == "status") {
                    status = obj[prop];
                }
            }
        }
    }

    console.log(status);
    console.log(extorderID);
    const ids = extorderID.split('_');
    const orderID = ids[0];
    const copmanyId = ids[1];
    const userID = ids[2];

    const userOrder = await admin.firestore().collection("users").doc(userID).collection("active_orders").doc(orderID);
    const companyOrder = await admin.firestore().collection("companies").doc(copmanyId).collection("active_orders").doc(orderID);

    updateStatus(userOrder);
    updateStatus(companyOrder);

    function updateStatus(order) {
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
    }

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
