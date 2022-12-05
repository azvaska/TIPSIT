const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const RoomSchema = new Schema({
    roomid: {
        type: String,
        unique: true,
    },
    name: {
        type: String,
        unique: true,
    },
    password:{
        type: String,
    },
    rsa_pubblic: {
        type: Buffer
    },
    rsa_private: {
        type: Buffer
    },
    block: {
        type: Array
    },
}, {timestamps: true});

const Room = mongoose.model('Room', RoomSchema);
module.exports = Room;