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


module.exports = {
     blockchain, abci_info, status
}
