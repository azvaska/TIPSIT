const express = require('express');
const router = express.Router();

const AuthController = require('../controllers/AuthController');
const ChatroomController = require('../controllers/ChatroomController');
const authenticate = require('../middleware/authenticate');


// Authenticaion
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/authenticate', authenticate);

// chat
router.post('/create-room', ChatroomController.createRoom);
router.post('/get-room', ChatroomController.getRoom);

module.exports = router;