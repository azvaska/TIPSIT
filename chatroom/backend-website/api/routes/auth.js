const express = require('express');
const router = express.Router();

const AuthController = require('../controllers/AuthController');
const MsgController = require('../controllers/MsgController');
const ChatroomController = require('../controllers/ChatroomController');
const authenticate = require('../middleware/authenticate');


// Authenticaion
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/authenticate', authenticate);

// Lotion
router.post('/blockchain', MsgController.blockchain);
router.post('/abci_info', MsgController.abci_info);
router.post('/status', MsgController.status);

// chat
router.post('/create-room', ChatroomController.createRoom);
router.post('/get-room', ChatroomController.getRoom);

module.exports = router;