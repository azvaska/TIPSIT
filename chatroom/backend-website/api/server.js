const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const app = express();
let { connect } = require('lotion')
const User = require('./models/User.js');
const Room = require('./models/Room');
const AuthRoute = require('./routes/auth');
const cors = require('cors');
const uuid = require('uuid');
const path_gense = "./genesis.json"
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
                        Room.findOne({ roomid: data.roomId }).then((room) => {
                            if (room) {
                                console.log("user joined room: " + data.roomId)
                                io.to(data.roomId).emit("JoinedRoom", {roomId:data.roomId, _id:user.userId})
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
                        Room.findOne({ roomid: data.roomId }).then(async (room) => {
                            if (room) {
                                let lc = await connect(null, {
                                    nodes:
                                        [`ws://localhost:30098/websocket`,], genesis: require(path_gense)
                                })

                                return await lc.send({
                                    _id: `${messageId}`,
                                    userId: `${data.userId}`,
                                    roomId: `${data.roomId}`,
                                    content: `${data.content}`,
                                    timestamp: `${Math.floor(new Date().getTime() / 1000)}`,
                                })
                                    .then(x => {
                                        room.block.push(x.height)
                                        room.save()
                                        .then(_ => {
                                            io.to(data.roomId).emit('new-message', msg);
                                        })
                                        .catch(err => {
                                            console.log(JSON.stringify(err))
                                        })
                                    })
                                    .catch(err => console.log(err));
                            }
                        })
                    }
                })
        }
    });
});



const PORT = 3080;

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





app.use('/api', AuthRoute);
http.listen(3000, function () {
    console.log('listening on *:3000 for socket.io');
});
app.listen(PORT, () => console.log(`[INFO] Server listening on port ${PORT}`));

