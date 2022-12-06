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
                        console.log(crypto)
                        const md = crypto.createHash('sha256');
                        md.update(password + " " + name_room);
                        const password_derivative = md.digest('hex');
                        const iv = crypto.webcrypto.getRandomValues(new Uint8Array(12));
                        // iv as utf-8 string
                        let iv_aes = Array.from(iv).map(b => String.fromCharCode(b)).join('');
                        // Deterministic key generation
                        iv_aes = b64EncodeUnicode(iv_aes)
                        console.log("generation")
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
                                    , iv: iv_aes, username:user.user, password: password_derivative, chatId: chat_id
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
    let name = req.body.name;
    let password = req.body.password;
    const md = forge.md.sha512.create();
    md.update(password);
    md.update(" " + name);
    const seed = md.digest().toHex();
    if (password !== "test") {
        res.statusMessage = "A room with that password or name does not exist.";
        return res.status(400);
    }
    const prng = forge.random.createInstance()
    prng.seedFileSync = () => seed
    chat_id = "3334433"
    // Deterministic key generation
    const { privateKey, publicKey } = forge.pki.rsa.generateKeyPair({ bits: 4096, prng })

    console.log(privateKey)

    res.send({ privateKey: privateKey, publicKey: publicKey, chatId: chat_id })
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
const getMessages = (req, res, next) => {
    let userId = req.body.userId;
    let roomId = req.body.roomId;
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
                    messages: messages
                })
            })
        })
        .catch(err => {
            console.log(err);
        })
}

module.exports = {
    createRoom, getRoom, getMessages
}