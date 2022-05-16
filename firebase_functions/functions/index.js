const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");

const admin = require("firebase-admin");
admin.initializeApp();

const app = express();

app.post("/", async (req, res) => {
    var status;
    var extOrderID;
    iterateObject(req.body);

    function iterateObject(obj) {
        for (prop in obj) {
            if (typeof (obj[prop]) == "object") {
                iterateObject(obj[prop]);

            } else {
                if (prop == "extOrderId") {
                    extOrderID = obj[prop];
                }
                if (prop == "status") {
                    status = obj[prop];
                }
            }
        }
    }

    console.log(status);
    console.log(extOrderID);
    const ids = extOrderID.split('_');
    const orderID = ids[0];
    const companyID = ids[1];
    const userID = ids[2];

    const userOrder = await admin.firestore().collection("customers").doc(userID).collection("active_orders").doc(orderID);
    const companyOrder = await admin.firestore().collection("companies").doc(companyID).collection("active_orders").doc(orderID);

    updateStatus(userOrder);
    updateStatus(companyOrder);

    function updateStatus(order) {
        order.get().then((doc) => {
            if (doc.exists) {
                console.log("order:");
                console.log(doc.data().orderID);
                if (status == 'COMPLETED') {
                    console.log("order2:");
                    console.log(doc.data().orderID);
                    order.update({ 'status': 'WAITING' })
                        .catch(err => {
                            console.log("Document does not exist.", err);
                        })
                }
            } else {
                console.log("Document does not exist.", err)
            }
        }).catch(err => {
            console.log("Internal server error.", err);
        });
    }

    res.status(200).send();
});

exports.gatewayNotification = functions.https.onRequest(app);

exports.agregateOrderData = functions.firestore.document('/companies/{companyID}/passive_orders/{date}/orders/{orderID}')
    .onCreate(async (snap, context) => {
        const companyID = context.params.companyID;
        const date = context.params.date;

        const cell = await admin.firestore()
            .collection("companies").doc(companyID)
            .collection("passive_orders").doc(date);

        if (snap.data().status == 'ABORTED') {
            return null;
        } else {
            return cell.update({
                'numOfOrders': admin.firestore.FieldValue.increment(1),
                'totalIncome': admin.firestore.FieldValue.increment(snap.data().price),
                'lastOrderID': snap.data().orderID,
                'lastUpdated': admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true }).catch(err => {
                console.log("Document does not exist.", err);
            })
        }

    });

exports.agregateOrderProducts = functions.firestore.document('/companies/{companyID}/passive_orders/{date}/orders/{orderID}')
    .onCreate(async (snap, context) => {
        const companyID = context.params.companyID;
        const date = context.params.date;

        const cell = await admin.firestore()
            .collection("companies").doc(companyID)
            .collection("passive_orders").doc(date);

        if (snap.data().status == 'ABORTED') {
            return null;
        } else {
            return cell.get().then(doc => {
                if (!doc.exists) {
                    console.log('No such document!');
                    throw new Error('No such document!');
                } else {
                    const orderItems = snap.data().items;
                    var mapItems = {};
                    if (doc.data().items != null) {
                        mapItems = doc.data().items;
                    }

                    for (var key of Object.keys(orderItems)) {
                        const newKey = key.substring(0, 20);

                        if (mapItems.hasOwnProperty(newKey)) {
                            mapItems[newKey] = mapItems[newKey] + 1;
                        } else {
                            mapItems[newKey] = 1;
                        }
                    }

                    return cell.update({ 'items': mapItems }, { merge: true })
                        .catch(err => {
                            console.log("Document does not exist.", err);
                        })

                }
            }).catch(err => {
                console.log('Error getting document', err);
                return false;
            });
        }
    });

exports.agregateOrderStates = functions.firestore.document('/companies/{companyID}/passive_orders/{date}/orders/{orderID}')
    .onCreate(async (snap, context) => {
        const companyID = context.params.companyID;
        const date = context.params.date;

        const cell = await admin.firestore()
            .collection("companies").doc(companyID)
            .collection("passive_orders").doc(date);

        return cell.get().then(doc => {
            if (!doc.exists) {
                console.log('No such document!');
                throw new Error('No such document!');
            } else {
                const orderState = snap.data().status;
                var stateMap = {};

                if (doc.data().states != null) {
                    stateMap = doc.data().states;
                }

                if (stateMap.hasOwnProperty(orderState)) {
                    stateMap[orderState] = stateMap[orderState] + 1;
                } else {
                    stateMap[orderState] = 1;
                }

                return cell.update({ 'states': stateMap }, { merge: true })
                    .catch(err => {
                        console.log("Document does not exist.", err);
                    })
            }
        }).catch(err => {
            console.log('Error getting document', err);
            return false;
        });
    });

exports.scheduledCellCreation =
    functions.pubsub.schedule('10 0 * * *').onRun((context) => {
        console.log('This will be run every day at 00:10 AM UTC!');
    });

app.post("/", async (req, res) => {
    const message = req.body;

    await admin.firestore().collection('payu').add(message);

    res.status(200).send();
});

// exports.helloWorld = functions.https.onRequest((request, response) => {
//     response.send("Hello from Firebase!");
// });
