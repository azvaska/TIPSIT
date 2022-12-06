const express = require('express');
const router = express.Router();

const AuthController = require('../controllers/AuthController');
const MsgController = require('../controllers/MsgController');
const UserController = require('../controllers/UserController');
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
router.post('/send', MsgController.send);

// chat
router.post('/create-room', ChatroomController.createRoom);
router.post('/getMessages', UserController.getMessages);
router.post('/getBlockNumb', UserController.getBlockNumb);

module.exports = router;