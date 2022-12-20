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
const path_gense = "/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/backend-website/api/genesis.json"
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
            console.log(data)
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
                                        .then(sus => {
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

let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: path_gense,
    rpcPort: 30098,
    
    p2pPort: 30099,
    logTendermint: true,
    peers: ["894b34acbc0ef6f5e219c0948a3ee79fbd441dac@138.3.243.70:30094","60b8dc9f84ae24e280ba4556f74c419b9afd9487@138.3.243.70:30092"]
})


lotionapp.use((state, tx) => {
    state.messages.push({
        _id: tx._id,
        userId: tx.userId,
        roomId: tx.roomId,
        content: tx.content,
        timestamp: tx.timestamp,
      })
});

lotionapp.start(3000).then(async ({ GCI }) => {
    http.listen(3000, function () {
        console.log('listening on *:3000 for socket.io');
    });
    app.listen(PORT, () => console.log(`[INFO] Server listening on port ${PORT}`));
})
