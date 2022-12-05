const request = require('request');
let { connect } = require('lotion')
const User = require('../models/User.js');

const blockchain = (req, res, next) => {
    let minHeight = req.body.minHeight;
    let maxHeight = req.body.maxHeight;
    let link = "http://127.0.0.1:30092/blockchain?"
    if (minHeight !== undefined && minHeight !== null) {
        link = link + "&minHeight=" + minHeight
    }
    if (maxHeight !== undefined && maxHeight !== null) {
        link = link + "&maxHeight=" + maxHeight
    }
    request(link, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            res.json(JSON.parse(body));
        }
    })
}

const abci_info = (req, res, next) => {
    request('http://127.0.0.1:30092/abci_info', function (error, response, body) {
        if (!error) {
            res.json(JSON.parse(body));
        }
    })
}

const status = (req, res, next) => {
    request('http://127.0.0.1:30092/status?', function (error, response, body) {
        if (!error) {
            res.json(JSON.parse(body));
        }
    })
}

const send = async (req, res, next) => {
    let messageId = '1234';

    let { state, send } = await connect(null, {
        nodes: [`ws://localhost:30092/websocket`,],
        genesis: require('../genesis.json')
    })

    await state;
    
    await send({
        _id: `${messageId}`,
        senderId: `${req.body.senderId}`,
        destinationId: `${req.body.destinationId}`,
        content: req.body.content,
        timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
    })
    .then(x => {
        res.json({
            message: "mandato messaggio",
            height: x.height
        })

        const query = { userId: req.body.senderId };

        User.findOneAndUpdate(query,
        { "$push": {"block": x.height} },
        { "new": true, "upsert": true },
        function (err, managerparent) {
            if (err) throw err;
        });

        const query2 = { userId: req.body.destinationId };

        User.findOneAndUpdate(query2, 
        { "$push": {"block": x.height} },
        { "new": true, "upsert": true },
        function (err, managerparent) {
            if (err) throw err;
        });
    })
    .catch(err => console.log(err));
}

module.exports = {
    send, blockchain, abci_info, status
}
