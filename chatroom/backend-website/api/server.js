const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const app = express();
const request = require('request');
let { connect } = require('lotion')
const User = require('../models/User.js');
const Room = require('../models/Room');
const AuthRoute = require('./routes/auth');
const cors = require('cors');
const http = require('http').Server(app);
const io = require('socket.io')(http, {
    cors: {
        origin: '*',
    }
});

io.on('connection', function (socket) {
    console.log('A user connected');
    socket.on('disconnect', function () {
        console.log('A user disconnected');
    });
    socket.on('join', function (data) {{
        User.findOne({ userId: data.userId })
            .then((user) => {
                if (user) {
                    Room.findOne({ roomId: data.roomId }).then((room) => {
                        if (room) {
                            socket.join(data.roomId);
                        }})}
    })}
});


http.listen(3000, function () {
    console.log('listening on *:3000');
});

PORT = 3080;

// db connection
const uri = "mongodb+srv://scimmia:bicistampante9@cluster0.jrjyogj.mongodb.net/?retryWrites=true&w=majority";
mongoose.connect(uri);
const db = mongoose.connection;

db.on('error', (err) => {
    console.error("[ERROR] " + err)
});

db.on('open', () => {
    console.log("[INFO] Connected to db")
});

// server rules
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());


app.listen(PORT, () => console.log(`[INFO] Server listening on port ${PORT}`));



app.use('/api', AuthRoute);
// app.get("/sus", async(req, res) => {
//     let messageId = '1234';
//     let lc = await connect(null,{nodes:
//         [`ws://localhost:30098/websocket`,], genesis: require('/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/blockchain-chat/api/genesis.json')
//      })
//    console.log(await lc.send({
//     _id: `${messageId}`,
//     senderId: `sus`,
//     destinationId: `sas`,
//     content: "sas",
//     timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
// }));
    // console.log("statusssda" );
    // await send({
    //     _id: `${messageId}`,
    //     senderId: `sus`,
    //     destinationId: `sas`,
    //     content: "sas",
    //     timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
    // })
    // .then(x => {
    //     console.log("sent");
    //     console.log(x);
    // })
    // .catch(err => console.log(err));

let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: '/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/backend-website/api/genesis.json',
    rpcPort: 30098,
    p2pPort:30099,
    logTendermint: true,
    peers: ["e54e41945e037994795f0f67b47835063ed911e9@172.18.5.10:30094","f1ec6aa15685b554b2d4dfd6dd7d8deb6d5946bd@172.18.5.11:30092"]
})


lotionapp.use((state, tx) => {
  console.log(JSON.stringify(state));
  console.log(JSON.stringify(tx));
  console.log("new messagge")
  io.emit("new-message", "nabbo");

  state.messages.push({
    _id: tx._id,
    senderId: tx.senderId,
    destinationId: tx.destinationId,
    content: tx.content,
    timestamp: tx.timestamp
    })
});

lotionapp.start(3000).then(async ({ GCI }) => {
    console.log(GCI)
    console.log("Lotion started")
})
