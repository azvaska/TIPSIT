# Secure Chatroom

A chatroom that is secure and stores everymessage in a blockchain
<br>
This is a simple chatroot where you can create many rooms and each message will be encrypted with AES encryption before being sent to the blockchain.
There are many different ways you can interact with the chatroot, the website and the mobile app
Mongodb is used to store rooms information and user data. 
The backend server is written in node.js (Express) and for the websocket connection it uses [Socket.IO](https://socket.io/).
## Features
- Login/Register
- aes encryption
- blockchain
- password based rooms
- website
- mongodb

## In depth
### Blockchain
The blockchain is implemented thanks to the library  [lotionjs](https://lotionjs.com/)
that uses thendermint as the underlying implementation of the blockchain.
The blockchain is made from 3 nodes.
### Websocket
The messaging part of the application is implemented thanks to the library Socket.IO that facilitates the code since it supports by default a feature called [rooms](https://socket.io/docs/v4/rooms/)
that can easly be used to put multiple clients together and send the new messages.
```js
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
```
### Website
Its a simple website written in Vue.js
### Encryption 
The client before sending the message to the server it will encrypt it with AES-GCM, which need a 'password' and a random set of characters called IV, the password is derived from the room name and password that are hashed and stored in the database and also the iv is stored in the database.
### Database
The MongoDB database stores the user information,
room name,password,iv and the blocks height that room has in the blockchain,without this you can't know what messages have been written in the room.
### Express Server
Simple server that handles the authentication with jwt token and the creation of the rooms and sending the messages to all the users connected.
Create a room
```js
 User.findOne({ userId: userId })
        .then((user) => {
            if (user) {
                Room.findOne({ name: name_room }).then((room) => {
                    if (room) {
                        res.status(400).json({ message: "A room with that name already exists." })
                        return 0;

                    } else {
                        const md = crypto.createHash('sha256');
                        md.update(password + " " + name_room);
                        const password_derivative = md.digest('hex');
                        const iv = crypto.webcrypto.getRandomValues(new Uint8Array(12));
                        // iv as utf-8 string
                        let iv_aes = Array.from(iv).map(b => String.fromCharCode(b)).join('');
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
```
blockchain connection
```js
let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: path_gense,
    rpcPort: 30098,
    p2pPort: 30099,
    logTendermint: true,
    peers: ["39cf935eb23539af6506d3f5cdfbcc7af602bdb9@138.3.243.70:30094","8f08150f9c1300af4d8b4bccd7a0c1e2be5c6895@138.3.243.70:30092"]
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
   
})
```


## References
[expressjs](https://expressjs.com/it/)

[Mongodb](https://www.mongodb.com/it-it)

[Socket.io](https://socket.io/)

[AES-GCM](https://en.wikipedia.org/wiki/Galois/Counter_Mode)

