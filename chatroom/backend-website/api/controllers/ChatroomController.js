const User = require('../models/User.js');
const axios = require('axios');
const Room = require('../models/Room');
const qs = require('qs');
const uuid = require('uuid')
const crypto = require('crypto');



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
                                    , iv: iv_aes, username: user.user, password: password_derivative, chatId: chat_id,timestamp:room.createdAt
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
                        messages: messages,timestamp:room.createdAt
                    })
                    res.json({
                        message: 'Found the room Successfully!'
                        , iv: room.iv, password: room.password, chatId: room.roomid,
                        messages: messages,timestamp:room.createdAt
                    })
                    }
                console.log(blocks)
                const promises = new Promise(async (resolve, reject)  =>{
                    var messages_sus = [];
                    for (let i = 0; i < blocks.length; i++) {
                        try {
                            var response= await axios.get("http://localhost:30098/block?", {
                                params: {
                                    height: blocks[i]
                                }
                            })
                            if (response.status !== 200) {
                                console.log("Error: " + response)
                                return;
                            }
    
                            let data = response.data.result.block.data.txs[0];
                            let buff = Buffer.from(data, 'base64').toString();
                            let toAdd = JSON.parse(buff.substring(4, buff.length - 4));
                            // toAdd.username = username;
                            messages_sus.push(toAdd);
                            let h = response.data.result.block.header.height;
                            if (h == blocks[blocks.length - 1]) {
                                messages=messages_sus;
                                resolve(messages_sus);
                                return messages_sus;
    
                            }
                        } catch (error) {
                            
                        }

                    }
                    return messages_sus;
                });

                promises.then((messages_su) => {
                    messages.sort((a, b) => {
                        return a.timestamp - b.timestamp
                    });

                    res.json({
                        message: 'Found the room Successfully!'
                        , iv: room.iv, password: room.password, chatId: room.roomid,
                        messages: messages,timestamp:room.createdAt
                    })
                })

            }
            else {
                res.status(400).json({ message: "Wrong password!" })
            }
        }else{
            res.status(400).json({ message: "Room not found!" })
        }
    }).catch(err => {
        res.status(400).json({ message: "An error occurred!", error: err.message })
    })
}

module.exports = {
    createRoom, getRoom
}