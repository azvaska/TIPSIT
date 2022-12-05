const User = require('../models/User.js');
const axios = require('axios');
const Room = require('../models/Room');
const qs = require('qs');
const uuid = require('uuid')
import forge from "node-forge"


const createRoom = (req, res) => {
    let name = req.body.name;
    let password = req.body.password;
    let chat_id = uuid.v4();
    const md = forge.md.sha256.create();
    md.update(password);
    md.update(" "+name);
    const seed = md.digest().toHex();
    const prng = forge.random.createInstance();
    prng.seedFileSync = () => seed
    // Deterministic key generation
    const { privateKey, publicKey } = forge.pki.rsa.generateKeyPair({ bits: 4096, prng })

    let room = new Room({
        chatid: chat_id,
        name: req.body.email,
        password: hashedPass,
        userId: generateUserId(),
        rsa_pubblic: publicKey,
        rsa_private: privateKey,
        block: []
    })

    room.save()
        .then(room => {
            res.json({
                message: 'room Added Successfully!'
            })
        })
        .catch(err => {
            res.json({
                message: 'An error occurred!',
                error: err.message
            })
        })

    console.log(privateKey)
    res.send({privateKey: privateKey, publicKey: publicKey,chatId:chat_id})
}


const getRoom = (req, res) => {
    let name = req.body.name;
    let password = req.body.password;
    const md = forge.md.sha512.create();
    md.update(password);
    md.update(" "+name);
    const seed = md.digest().toHex();
    if (password !== "test"){
        res.statusMessage = "A room with that password or name does not exist.";
        return  res.status(400);
    }
    const prng = forge.random.createInstance()
    prng.seedFileSync = () => seed
    chat_id="3334433"
    // Deterministic key generation
    const { privateKey, publicKey } = forge.pki.rsa.generateKeyPair({ bits: 4096, prng })
    console.log(privateKey)

    res.send({privateKey: privateKey, publicKey: publicKey,chatId:chat_id})
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