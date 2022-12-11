const User = require('../models/User.js');
const axios = require('axios');
const Room = require('../models/Room');
const qs = require('qs');
const uuid = require('uuid')
const crypto = require('crypto');

function generateUserId() {
    return uuid.v4();
}

function b64EncodeUnicode(str) {

    return Buffer.from(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
        function toSolidBytes(match, p1) {
            return String.fromCharCode('0x' + p1);
        })).toString("base64");
}


const createRoom = (req, res) => {
    console.log("create room")
    let name_room = req.body.name;
    let password = req.body.password;
    let userId = req.body.userId;
    let chat_id = uuid.v4();
    User.findOne({ userId: userId })
        .then((user) => {
            if (user) {
                Room.findOne({ name: name_room }).then((room) => {
                    if (room) {
                        console.log(room)
                        res.status(400).json({ message: "A room with that name already exists." })
                        return 0;

                    } else {
                        const md = crypto.createHash('sha256');
                        md.update(password + " " + name_room);
                        const password_derivative = md.digest('hex');
                        const iv = crypto.webcrypto.getRandomValues(new Uint8Array(12));
                        // iv as utf-8 string
                        let iv_aes = Array.from(iv).map(b => String.fromCharCode(b)).join('');
                        // Deterministic key generation
                        iv_aes = b64EncodeUnicode(iv_aes)
                        let room = new Room({
                            roomid: chat_id,
                            name: name_room,
                            password: password_derivative,
                            iv: iv_aes,
                            owner_userId: userId,
                            block: []
                        })

                        room.save()
                            .then(room => {
                                res.json({
                                    message: 'room Added Successfully!'
                                    , iv: iv_aes, username: user.user, password: password_derivative, chatId: chat_id
                                })
                            })
                            .catch(err => {
                                console.log(err)
                                res.status(400).json({
                                    message: 'An error occurred!',
                                    error: err.message
                                })
                            })
                    }
                })
            }
        }).catch(err => {
            res.status(400).json({ message: "An error occurred!", error: err.message })
        })
}


const getRoom = (req, res) => {
    let name_r = req.body.name;
    let password = req.body.password;
    Room.findOne({ name: name_r }).then(async (room) => {
        if (room) {
            console.log(room)

            const md = crypto.createHash('sha256');
            md.update(password + " " + name_r);
            const password_derivative = md.digest('hex');
            if (room.password === password_derivative) {
                let messages = [];

                let blocks = room.block;
                if (blocks.length == 0) {
                    console.log({
                        message: 'Found the room Successfully!'
                        , iv: room.iv, password: room.password, chatId: room.roomid,
                        messages: messages
                    })
                    res.json({
                        message: 'Found the room Successfully!'
                        , iv: room.iv, password: room.password, chatId: room.roomid,
                        messages: messages
                    })
                    }
                console.log(blocks)
                const promises = new Promise((resolve, reject) => {
                    for (let i = 0; i < blocks.length; i++) {
                        axios.get("http://localhost:30098/block?", {
                            params: {
                                height: blocks[i]
                            }
                        })
                            .then((response) => {
                                console.log("GOT BLOCK")
                                if (response.status !== 200) {
                                    console.log("Error: " + response)
                                    return;
                                }

                                let data = response.data.result.block.data.txs[0];
                                let buff = Buffer.from(data, 'base64').toString();
                                let toAdd = JSON.parse(buff.substring(4, buff.length - 4));
                                // toAdd.username = username;
                                messages.push(toAdd);
                                console.log(toAdd)

                                let h = response.data.result.block.header.height;
                                if (h == blocks[blocks.length - 1]) {
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
                        message: 'Found the room Successfully!'
                        , iv: room.iv, password: room.password, chatId: room.roomid,
                        messages: messages
                    })
                })

            }
            else {
                res.status(400).json({ message: "Wrong password!" })
            }
        }
    }).catch(err => {
        res.status(400).json({ message: "An error occurred!", error: err.message })
    })
}
/*
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
*/
// const getMessages = (req, res, next) => {
//     let userId = req.body.userId;
//     let roomId = req.body.roomId;
//     let blocks;
//     let username;
//     Room.findOne({ roomId: roomId })
//         .then((user) => {

// }

module.exports = {
    createRoom, getRoom
}