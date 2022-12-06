const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const RoomSchema = new Schema({
    roomid: {
        type: String,
        unique: true,
        required:true
    },
    name: {
        type: String,
        unique: true,
        required:true
    },
    owner_userId:{
        type: String
    },
    password:{
        type: String,
        required:true
    },
    iv: {
        type: String
    },
    block: {
        type: Array
    },
}, {timestamps: true});

const Room = mongoose.model('Room', RoomSchema);
module.exports = Room;