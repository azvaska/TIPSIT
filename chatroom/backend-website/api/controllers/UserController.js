const User = require('../models/User.js');
const axios = require('axios');
const qs = require('qs');

const getUser = (req, res, next) => {
    let userId = req.body.userId;

    User.findOne({ userId: userId })
        .then((user) => {
            if (user) {
                res.json({
                    userId: user.userId,
                    username: user.user,
                    message: 'User found',
                })
            } else {
                res.json({
                    error: 'User Not Found'
                })
            }
        });
}

const getBlockNumb = (req, res, next) => {
    let userId = req.body.userId;
    
    User.findOne({ userId: userId })
        .then((user) => {
            res.JSON({
                number: user.block.length
            })
        })
        .catch(err => {
            console.error(err);
        })
}

const getMessages = (req, res, next) => {
    let userId = req.body.userId;
    let blocks;
    let messages = [];
    let username;
    User.findOne({ userId: userId })
        .then((user) => {
            blocks = user.block;
            username = user.user;
            const promises = new Promise((resolve, reject) => {
                for (let i = 0; i < blocks.length; i++) {
                    axios.get("http://52.28.217.148:30096/block?", {
                        params: {
                            height: blocks[i]
                        }
                    })
                        .then((response) => {
                            if (response.status !== 200) {
                                return;
                            }
                            
                            let data = response.data.result.block.data.txs[0];
                            let buff = Buffer.from(data, 'base64').toString();
                            let toAdd = JSON.parse(buff.substring(4, buff.length - 4));
                            toAdd.username = username;
                            messages.push(toAdd);

                            let h = response.data.result.block.header.height;
                            if(h == blocks[blocks.length - 1]) {
                                setTimeout(() => {
                                    resolve();
                                }, 300);
                            }
                        })
                        .catch((err) => {
                            console.log(err)
                        })
                }
            });
            
            promises.then(() => {
                messages.sort((a, b) => {
                    return b.timestamp - a.timestamp
                });

                res.json({
                    messages: messages
                })
            })
        })
        .catch(err => {
            console.log(err);
        })
}

module.exports = {
    getUser, getMessages, getBlockNumb
}