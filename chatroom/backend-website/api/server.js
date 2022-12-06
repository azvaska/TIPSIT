const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const app = express();
const request = require('request');
let { connect } = require('lotion')
const User = require('./models/User.js');
const Room = require('./models/Room');
const AuthRoute = require('./routes/auth');
const cors = require('cors');
const uuid = require('uuid');

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
    socket.on('join', function (data) {
        {
            User.findOne({ userId: data.userId })
                .then((user) => {
                    if (user) {
                        Room.findOne({ roomId: data.roomId }).then((room) => {
                            if (room) {
                                console.log("user joined room: " + data.roomId)
                                socket.join(data.roomId);
                            }
                        })
                    }
                })
        }
    });
    socket.on('message', function (data) {
        {
            let messageId = uuid.v4();
            let msg = {
                _id: `${messageId}`,
                userId: `${data.userId}`,
                roomId: `${data.roomId}`,
                content: `${data.content}`,
                timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
            }
            User.findOne({ userId: data.userId })
                .then((user) => {
                    if (user) {
                        Room.findOne({ roomId: data.roomId }).then(async (room) => {
                            if (room) {
                                let lc = await connect(null, {
                                    nodes:
                                        [`ws://localhost:30098/websocket`,], genesis: require('/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/backend-website/api/genesis.json')
                                })

                                return await lc.send({
                                    _id: `${messageId}`,
                                    userId: `${data.userId}`,
                                    roomId: `${data.roomId}`,
                                    content: `${data.content}`,
                                    timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
                                })
                                    .then(x => {
                                        console.log("message sent to the blockchain" + Object.values(x));
                                        io.to(data.roomId).emit('new-message', msg);
                                    })
                                    .catch(err => console.log(err));
                            }
                        })
                    }
                })
        }
    });
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

let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: '/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/backend-website/api/genesis.json',
    rpcPort: 30098,
    p2pPort: 30099,
    logTendermint: true,
    peers: ["16eab664372ed17a72177cd698371dec67613861@172.18.5.10:30094","ff12b6e5e47b47002494149a963dd10f1e92a4c8@172.18.5.11:30092"]
})


lotionapp.use((state, tx) => {
    console.log("new message received: " + tx);
    // io.to(tx.roomId).emit("new-message", tx);
    state.messages.push({
        _id: tx._id,
        userId: tx.userId,
        roomId: tx.roomId,
        content: tx.content,
        timestamp: tx.timestamp,
      })
});

lotionapp.start(3000).then(async ({ GCI }) => {
    console.log(GCI)
    console.log("Lotion started")
})
