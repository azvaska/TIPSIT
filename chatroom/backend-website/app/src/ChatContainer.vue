<template>
	<div class="window-container" :class="{ 'window-mobile': isDevice }">
		<div v-if="ErrorRoom">Error: {{ ErrorRoom }}</div>
		<form v-if="addNewRoom" @submit.prevent="createRoom">
			<input v-model="RoomName" type="text" placeholder="Room name" />
			<input v-model="PasswordNewRoom" type="Password" placeholder="Password of the room" />

			<button type="submit" :disabled="(disableForm || !RoomName || !PasswordNewRoom)">
				Create Room
			</button>
			<button @click="(joinRoom = true)" type="submit" :disabled="(disableForm || !RoomName || !PasswordNewRoom)">
				Join Room
			</button>
			<button class="button-cancel" @click="addNewRoom = false">Cancel</button>
		</form>
		<chat-window :height="screenHeight" :theme="theme"
		:styles="styles" :username-options="userOption"  :current-user-id="currentUserId"
			:room-id="roomId" :rooms="loadedRooms" :loading-rooms="loadingRooms" :messages="messages"
			:show-audio="false" :show-files="false"
			:messages-loaded="messagesLoaded" :rooms-loaded="roomsLoaded" :room-actions="roomActions"
			:menu-actions="menuActions" :room-message="roomMessage" :templates-text="templatesText"
			@fetch-messages="fetchMessages" @send-message="sendMessage" @add-room="addRoom"
			>
			<!-- <template #emoji-picker="{ emojiOpened, addEmoji }">
				<button @click="addEmoji({ unicode: '😁' })">
					{{ emojiOpened }}
				</button>
			</template> -->
		</chat-window>
	</div>
</template>

<script>

import ChatWindow from 'vue-advanced-chat'
import 'vue-advanced-chat/dist/vue-advanced-chat.css'
import { decrypt, encrypt, fromBinary } from "./utils/crypto"
import  Config  from "./utils/config"
const axios = require('axios').default;
const qs = require('qs');
const ip_addr= Config.ip_addr;
export default {
	components: {
		ChatWindow
	},

	props: {
		currentUserId: { type: String, required: true },
		theme: { type: String, required: true },
		isDevice: { type: Boolean, required: true },
	},

	data() {
		return {
			roomsPerPage: 15,
			rooms: [],
			userOption:{ minUsers: 1,currentUser:this.currentUserId},
			roomId: '',
			joinRoom: false,
			startRooms: null,
			endRooms: null,
			roomsLoaded: false,
			loadingRooms: true,
			allUsers: [],
			loadingLastMessageByRoom: 0,
			roomsLoadedCount: false,
			selectedRoom: null,
			messagesPerPage: 20,
			messages: [],
			messagesLoaded: false,
			roomMessage: '',
			lastLoadedMessage: null,
			previousLastLoadedMessage: null,
			roomsListeners: [],
			listeners: [],
			typingMessageCache: '',
			disableForm: false,
			addNewRoom: null,
			RoomName: '',
			PasswordNewRoom: '',
			ErrorRoom: '',
			inviteRoomId: null,
			invitedUsername: '',
			removeRoomId: null,
			ivStr: '',
			pwHash: '',
			
			removeUserId: '',
			removeUsers: [],
			roomActions: [
				//{ name: 'removeUser', title: 'Remove User' },
				{ name: 'deleteRoom', title: 'Delete Room' }
			],
			menuActions: [
				//{ name: 'inviteUser', title: 'Invite User' },
				//{ name: 'removeUser', title: 'Remove User' },
				{ name: 'deleteRoom', title: 'Delete Room' }
			],
			styles: { container: { borderRadius: '4px' } },
			templatesText: [ // like command
				{
					tag: 'help',
					text: 'This is the help'
				},
				{
					tag: 'action',
					text: 'This is the action'
				},
				{
					tag: 'action 2',
					text: 'This is the second action'
				}
			],
			// ,dbRequestCount: 0

			fetchedMessages: [],

			socketMessage: ''
		}
	},

	computed: {
		loadedRooms() {
			return this.rooms.slice(0, this.roomsLoadedCount)
		},
		screenHeight() {
			return this.isDevice ? window.innerHeight + 'px' : '100vh'
		}
	},

	mounted() {
		this.$soketio.on('joinRoom', async (data) => {
			let room = null;
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == data.roomId) {
					room = this.rooms[i]
				}
			}
			if (room == null) {
				console.log("Room not found" + data.roomId)
				return;
			}
			room.users.push({_id: data.userId, username: data.userId})
		})

		this.$soketio.on('new-message', async (data) => {
			let room = null;
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == data.roomId) {
					room = this.rooms[i]
				}
			}
			if (room == null) {
				console.log("Room not found" + data.roomId)
				return;
			}
			let message = {
				_id: data._id,
				roomId: data.roomId,
				senderId: data.userId,
				content: await decrypt(room.iv, data.content, room.password),
				timestamp: data.timestamp,
				username : data.userId,
			};
			this.fetchedMessages.push(message);
			room.lastMessage = this.formatMessage(room, message)
			this.fetchMessages({room ,options: {reset: true}})
		})
		this.fetchRooms()
		//await checkNewMsg();
	},

	methods: {
		pingServer() {
			// Send the "pingServer" event to the server.
			this.$socket.emit('pingServer', 'PING!')
		},


		resetRooms() {
			this.loadingRooms = true
			this.loadingLastMessageByRoom = 0
			this.roomsLoadedCount = 0
			this.rooms = []
			this.messages = []
			this.fetchedMessages = []
			this.roomsLoaded = true
			this.startRooms = null
			this.endRooms = null
			this.roomsListeners.forEach(listener => listener())
			this.roomsListeners = []
			this.resetMessages()
		},

		resetMessages() {
			this.messages = []
			this.messagesLoaded = false
			this.lastLoadedMessage = null
			this.previousLastLoadedMessage = null
			this.listeners.forEach(listener => listener())
			this.listeners = []
		},

		fetchRooms() {

			this.resetRooms()
			this.loadingRooms = false
		},

		async getRoom() {
			console.log("joining room");

			// if (this.endRooms && !this.startRooms) {
			// 	this.roomsLoaded = true
			// 	return
			// }


			axios.post(`http://${ip_addr}:3080/api/get-room`, {
				name: this.RoomName,
				password: this.PasswordNewRoom,
				userId: this.currentUserId,
			}).then( async response => {
				const sus = async (msg) => {
						msg.senderId = msg.userId;
						msg.username = msg.userId;
						msg.content = await decrypt(fromBinary(response.data.iv), msg.content, response.data.password);
						return msg
				}
				let actions = response.data.messages.map(sus); // run the function over all items
				let results = await  Promise.all(actions); // pass array of promises
				let users=new Set();
				results.forEach((msg) => {
					users.add(msg.senderId)
								})
				this.fetchedMessages = this.fetchedMessages.concat(results);
				// Messaggi fetchati nell'array
				let user_room = [];
				users.forEach((user)=>{
					user_room.push({
						_id: user,
						username: user,
					})
				})
				const roomList = [];
				let room = {};

				room.roomId = response.data.chatId;
				room.roomName = this.RoomName;
				room.timestamp = new Date().toISOString();
				room.users = user_room

				room.avatar = 'https://www.meme-arsenal.com/memes/b6a18f0ffd345b22cd219ef0e73ea5fe.jpg';
				room.index = 0;
				room.iv = fromBinary(response.data.iv)
				room.password = response.data.password
				room.lastMessage = this.formatMessage(room, this.fetchedMessages[this.fetchedMessages.length - 1] || null) ;
				this.roomsLoadedCount += 1;
				this.ErrorRoom = null

				roomList.push(room);

				//this.listenLastMessage(room);
				this.rooms = this.rooms.concat(roomList);
				this.roomsLoaded = true;
				this.loadingRooms = false
				this.addNewRoom = false;

				if (!this.rooms.length) {
					this.loadingRooms = false
					// this.roomsLoadedCount = 1
				}
				this.$soketio.emit('join', { roomId: room.roomId, userId: this.currentUserId });

				this.fetchMessages({room, options: {reset: true}})
			}).catch((error) => {
					this.ErrorRoom = error.response.data.message;
					this.resetForms();
			this.addNewRoom = true;
			this.joinRoom = false;


				});
		},

		fetchMessages({ room, options = {} }) {
			// TODO carico solo i messaggi della chat che ho selezionato siummm
			if (options.reset) {
				this.resetMessages()
				this.roomId = room.roomId
			}


			// maybe cancella
			// if (this.previousLastLoadedMessage && !this.lastLoadedMessage) {
			// 	this.messagesLoaded = true
			// 	return
			// }

			this.selectedRoom = room.roomId

			// prendo i messaggi solo di quella stanza

			if (options.reset) this.messages = []

			this.fetchedMessages.forEach(message => {
				if (message.roomId == room.roomId){
					const formattedMessage = this.formatMessage(room, message)
					this.messages.push(formattedMessage);
				}
			})

			if (this.lastLoadedMessage) {
				this.previousLastLoadedMessage = this.lastLoadedMessage
			}

			this.messagesLoaded = true

			//this.listenMessages(room)
		},
		formatMessage(room, message) {
			let date = new Date(message.timestamp * 1000);
			const formattedMessage = {
				...message,
				...{
					seconds: date.getSeconds(),
					seen: true,
					timestamp: `${date.getHours()}:${date.getMinutes()}`,
					date: date.toISOString().split('T')[0],
					// avatar: senderUser ? senderUser.avatar : null,
					distributed: true
				}
			}

			return formattedMessage
		},

		async sendMessage({ content, roomId, files }) {
			let room = {}
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == roomId) {
					room = this.rooms[i]
				}
			}
			let message = {
				userId: this.currentUserId,
				roomId: roomId,
				content: await encrypt(room.iv, content, room.password),
				timestamp: Math.floor(new Date().getTime() / 1000)
			}
			if (files) {
				files = null;
			}
			this.$soketio.emit('message', message);
			
		},


		addRoom() {
			console.log("addRoom");
			this.resetForms();
			this.addNewRoom = true;
		},

		async createRoom() {
			console.log("createRoom");
			console.log(this.joinRoom)
			if (this.joinRoom) {
				this.getRoom();
				return;
			}

			axios.post(`http://${ip_addr}:3080/api/create-room`, qs.stringify({
				userId: this.currentUserId,
				name: this.RoomName,
				password: this.PasswordNewRoom,

			}))
				.then((res) => {
					if (res.data.error) {
						console.log("non trovato");
						return;
					}
					this.disableForm = true
				this.joinRoom = false;
				this.addNewRoom = false;
					let userId = this.currentUserId;
					let username = res.data.username;
					let room = {};
					room.roomId = res.data.chatId;
					room.roomName = this.RoomName;
					room.timestamp = new Date().toISOString();
					room.iv = fromBinary(res.data.iv)
					room.password = res.data.password
					room.users = [
						{
							_id: userId,
							username: username
						}
					];

					room.avatar = 'https://www.meme-arsenal.com/memes/b6a18f0ffd345b22cd219ef0e73ea5fe.jpg';
					room.index = 0;
					var date=new Date();
					room.lastMessage = {
						height: 0,
						content: 'Stanza creata!',
						timestamp: `${date.getDay()}/${date.getMonth()}/${date.getFullYear()}`,
						seen: true,
					}
					this.ErrorRoom = null
					this.rooms.push(room);
					this.roomsLoadedCount += 1;
					this.roomsLoaded = true
					this.$soketio.emit('join', { roomId: room.roomId, userId: userId });
					//this.listenLastMessage(room);


				})
				.catch((error) => {
					this.ErrorRoom = error.response.data.message
					this.addRoom()
					this.joinRoom = false;
				})

			this.addNewRoom = false
			this.addRoomUsername = ''
			//this.fetchRooms()
		},

		resetForms() {
			this.disableForm = false
			this.addNewRoom = null
			this.addRoomUsername = ''
			this.inviteRoomId = null
			this.invitedUsername = ''
			this.removeRoomId = null
			this.removeUserId = ''
		}

	}

}
</script>

<style lang="scss" scoped>
.window-container {
	width: 100%;
}

.window-mobile {
	form {
		padding: 0 10px 10px;
	}
}

form {
	padding-bottom: 20px;
}

input {
	padding: 5px;
	width: 140px;
	height: 21px;
	border-radius: 4px;
	border: 1px solid #d2d6da;
	outline: none;
	font-size: 14px;
	vertical-align: middle;

	&::placeholder {
		color: #9ca6af;
	}
}

button {
	background: #1976d2;
	color: #fff;
	outline: none;
	cursor: pointer;
	border-radius: 4px;
	padding: 8px 12px;
	margin-left: 10px;
	border: none;
	font-size: 14px;
	transition: 0.3s;
	vertical-align: middle;

	&:hover {
		opacity: 0.8;
	}

	&:active {
		opacity: 0.6;
	}

	&:disabled {
		cursor: initial;
		background: #c6c9cc;
		opacity: 0.6;
	}
}

.button-cancel {
	color: #a8aeb3;
	background: none;
	margin-left: 5px;
}

select {
	vertical-align: middle;
	height: 33px;
	width: 152px;
	font-size: 13px;
	margin: 0 !important;
}
</style>