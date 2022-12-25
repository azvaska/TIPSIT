const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UserSchema = new Schema({
    user: {
        type: String,
    },
    email: {
        type: String,
        lowercase: true,
        unique: true,
    },
    password: {
        type: String
    },
    userId: {
        type: String,
        unique: true,
    },
}, {timestamps: true});

const User = mongoose.model('User', UserSchema);
module.exports = User;