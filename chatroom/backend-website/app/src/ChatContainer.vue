<template>
	<div class="window-container" :class="{ 'window-mobile': isDevice }">
		<div v-if="ErrorCreateRoom">Error: {{ ErrorCreateRoom }}</div>
		<form v-if="addNewRoom" @submit.prevent="createRoom">
			<input v-model="RoomName" type="text" placeholder="Room name" />
			<input v-model="PasswordNewRoom" type="Password" placeholder="Password of the room" />

			<button type="submit" :disabled="(disableForm || !RoomName || !PasswordNewRoom)">
				Create Room
			</button>
			<button class="button-cancel" @click="addNewRoom = false">Cancel</button>
		</form>
		<chat-window :height="screenHeight" :theme="theme" :styles="styles" :current-user-id="currentUserId"
			:room-id="roomId" :rooms="loadedRooms" :loading-rooms="loadingRooms" :messages="messages"
			:messages-loaded="messagesLoaded" :rooms-loaded="roomsLoaded" :room-actions="roomActions"
			:menu-actions="menuActions" :room-message="roomMessage" :templates-text="templatesText"
			@fetch-more-rooms="fetchMoreRooms" @fetch-messages="fetchMessages" @send-message="sendMessage"
			@open-file="openFile" @open-user-tag="openUserTag" @add-room="addRoom"
			@room-action-handler="menuActionHandler" @menu-action-handler="menuActionHandler">
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
import {decrypt,encrypt,fromBinary} from "./utils/crypto"
const axios = require('axios').default;
const qs = require('qs');

export default {
	components: {
		ChatWindow
	},

	props: {
		currentUserId: { type: String, required: true },
		theme: { type: String, required: true },
		isDevice: { type: Boolean, required: true }
	},

	data() {
		return {
			roomsPerPage: 15,
			rooms: [],
			roomId: '',
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
			ErrorCreateRoom: '',
			inviteRoomId: null,
			invitedUsername: '',
			removeRoomId: null,
			ivStr:'',
			pwHash:'',
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
			console.log(this.rooms.slice(0, this.roomsLoadedCount))
			return this.rooms.slice(0, this.roomsLoadedCount)
		},
		screenHeight() {
			return this.isDevice ? window.innerHeight + 'px' : 'calc(100vh - 80px)'
		}
	},

	mounted() {
		this.$soketio.on('new-message', async (data) => {
			let room=null;
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == data.roomId) {
					room=this.rooms[i]
				}
			}
			console.log(await decrypt(room.iv,data.content,room.password))
			console.log("New message")
			this.messages.push({
				roomId: data.roomId,
				userId: data.userId,
				content: await decrypt(room.iv,data.content,room.password),
				createdAt: data.createdAt
			})
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

		/*async checkNewMsg() {
			while (true) {
				setTimeout(() => {
					axios.post('http://localhost:3080/api/getBlockNumb', qs.stringify({
						userId: this.currentUserId
					}))
					.then((response) => {
						if(response.data.number != this.fetchedMessages.length) {
							this.fetchRooms();
						}
					})
				}, 3000)
			}
		},*/

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
			this.fetchMoreRooms()
			this.loadingRooms = false
		},

		async fetchMoreRooms() {
			console.log("fetching more rooms...");

			if (this.endRooms && !this.startRooms) {
				this.roomsLoaded = true
				return
			}

			let tempMsg = [];

			axios.post("http://localhost:3080/api/getMessages", {
				userId: this.currentUserId,
			}).then(response => {
				response.data.messages.forEach(msg => {
					tempMsg.push(msg)
				})
				this.fetchedMessages = this.fetchedMessages.concat(tempMsg);
				// Messaggi fetchati nell'array

				const roomList = [];
				// creo le stanze 
				// TODO forse mettere l'username diretto 

				let uu = [];
				// this.fetchedMessages.forEach(msg => {
				// 	let userId = msg.userId;
				// 	let destinationId = msg.destinationId;

				// 	let userId;
				// 	if (userId == this.currentUserId) userId = destinationId;
				// 	else userId = userId;

				// 	if (uu.find(element => element == userId) == undefined) {
				// 		uu.push(userId);
				// 	}
				// })

				uu.forEach(id => {
					let room = {};

					room.roomId = id;
					room.roomName = id;

					room.users = [
						{
							_id: id,
							username: id
						}
					];

					room.avatar = 'https://www.meme-arsenal.com/memes/b6a18f0ffd345b22cd219ef0e73ea5fe.jpg';
					room.index = 0;
					room.lastMessage = {
						height: 0,
						content: 'Stanza fetchata!',
						timestamp: `${new Date().getHours()}:${new Date().getMinutes()}`
					}
					roomList.push(room);

					//this.listenLastMessage(room);
					this.roomsLoadedCount += 1;


				})
				this.rooms = this.rooms.concat(roomList);
				this.roomsLoaded = true;
				console.log(this.rooms);
				this.loadingRooms = false

				if (!this.rooms.length) {
					this.loadingRooms = false
					this.roomsLoadedCount = 0
				}
			});
			/*
			this.listenUsersOnlineStatus(formattedRooms)
			this.listenRooms(query)
			// setTimeout(() => console.log('TOTAL', this.dbRequestCount), 2000)
			*/
		},

		/*
		listenLastMessage(room) {
			const listener = firestoreService.listenLastMessage(
				room.roomId,
				messages => {
	
					messages.forEach(message => {
						const lastMessage = this.formatLastMessage(message, room)
						const roomIndex = this.rooms.findIndex(
							r => room.roomId === r.roomId
						)
						this.rooms[roomIndex].lastMessage = lastMessage
						this.rooms = [...this.rooms]
					})
					if (this.loadingLastMessageByRoom < this.rooms.length) {
						this.loadingLastMessageByRoom++
	
						if (this.loadingLastMessageByRoom === this.rooms.length) {
							this.loadingRooms = false
							this.roomsLoadedCount = this.rooms.length
						}
					}
				}
			)
	
			this.roomsListeners.push(listener)
		},
	
		formatLastMessage(message, room) {
			if (!message.timestamp) return
	
			let content = message.content
			if (message.files?.length) {
				const file = message.files[0]
				content = `${file.name}.${file.extension || file.type}`
			}
	
			const username =
				message.sender_id !== this.currentUserId
					? room.users.find(user => message.sender_id === user._id)?.username
					: ''
	
			return {
				...message,
				...{
					content,
					timestamp: formatTimestamp(
						new Date(message.timestamp.seconds * 1000),
						message.timestamp
					),
					username: username,
					distributed: true,
					seen: message.sender_id === this.currentUserId ? message.seen : null,
					new:
						message.sender_id !== this.currentUserId &&
						(!message.seen || !message.seen[this.currentUserId])
				}
			}
		},
		*/
		fetchMessages({ room, options = {} }) {
			// TODO carico solo i messaggi della chat che ho selezionato siummm
			if (options.reset) {
				this.resetMessages()
				this.roomId = room.roomId
			}


			// maybe cancella
			if (this.previousLastLoadedMessage && !this.lastLoadedMessage) {
				this.messagesLoaded = true
				return
			}

			this.selectedRoom = room.roomId

			// prendo i messaggi solo di quella stanza
			let temp = [];
			this.fetchedMessages.forEach(msg => {
				let userId = msg.userId;
				let destinationId = msg.destinationId;

				let userId;
				if (userId == this.currentUserId) userId = destinationId;
				else userId = userId;

				if (userId == room.roomId) {
					temp.push(msg);
				}
			})

			if (options.reset) this.messages = []

			temp.forEach(message => {
				const formattedMessage = this.formatMessage(room, message)
				this.messages.unshift(formattedMessage);
			})

			if (this.lastLoadedMessage) {
				this.previousLastLoadedMessage = this.lastLoadedMessage
			}

			this.messagesLoaded = true

			//this.listenMessages(room)
		},
		/*
		listenMessages(room) {
			const listener = firestoreService.listenMessages(
				room.roomId,
				this.lastLoadedMessage,
				this.previousLastLoadedMessage,
				messages => {
					messages.forEach(message => {
						const formattedMessage = this.formatMessage(room, message)
						const messageIndex = this.messages.findIndex(
							m => m._id === message.id
						)
	
						if (messageIndex === -1) {
							this.messages = this.messages.concat([formattedMessage])
						} else {
							this.messages[messageIndex] = formattedMessage
							this.messages = [...this.messages]
						}
	
						this.markMessagesSeen(room, message)
					})
				}
			)
			this.listeners.push(listener)
		},
	
		markMessagesSeen(room, message) {
			if (
				message.sender_id !== this.currentUserId &&
				(!message.seen || !message.seen[this.currentUserId])
			) {
				firestoreService.updateMessage(room.roomId, message.id, {
					[`seen.${this.currentUserId}`]: new Date()
				})
			}
		},
		*/
		formatMessage(room, message) {
			let date = new Date(message.timestamp * 1000);
			const formattedMessage = {
				...message,
				...{
					seconds: date.getSeconds(),
					seen: true,
					timestamp: `${date.getHours()}:${date.getMinutes()}`,
					date: `${date.getDay()}/${date.getMonth()}/${date.getFullYear()}`,
					username: room.users.find(user => message.sender_id === user._id)
						?.username,
					// avatar: senderUser ? senderUser.avatar : null,
					distributed: true
				}
			}

			return formattedMessage
		},

		async sendMessage({ content, roomId, files, replyMessage }) {
			console.log(replyMessage);
			let room={}
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == roomId) {
					room=this.rooms[i]
				}
			}
			let message = {
				userId: this.currentUserId,
				roomId:roomId,
				content: await encrypt(room.iv,content,room.password),
				timestamp: Math.floor(new Date().getTime() / 1000)
			}
			console.log(message)
			if (files) {
				files = null;
			}
			this.$soketio.emit('message', message);
			// axios.post("http://localhost:3080/api/send", {
			// 	userId: message.sender_id,
			// 	content: message.content,
			// 	destinationId: roomId
			// })
			// 	.then((response) => {
			// 		console.log(response.data.message);
			// 	})

			let date = new Date(message.timestamp * 1000)
			room.lastMessage.content = message.content;
			room.lastMessage.timestamp = `${date.getHours()}:${date.getMinutes()}`;
		},
		
		menuActionHandler({ action, roomId }) {
			switch (action.name) {
				case 'inviteUser':
					return this.inviteUser(roomId)
				case 'removeUser':
					return this.removeUser(roomId)
				case 'deleteRoom':
					return this.deleteRoom(roomId)
			}
		},
		
		addRoom() {
			console.log("addRoom");
			this.resetForms();
			this.addNewRoom = true;
		},

		async createRoom() {
			console.log("createRoom");
			this.disableForm = true

			axios.post('http://localhost:3080/api/create-room', qs.stringify({
				userId: this.currentUserId,
				name: this.RoomName,
				password: this.PasswordNewRoom,
				
			}))
				.then((res) => {
					console.log(res.data);
					if (res.data.error) {
						console.log("non trovato");
						return;
					}
					let userId = this.currentUserId;
					let username = res.data.username;
					let room = {};
					room.roomId = res.data.chatId;
					room.roomName = this.RoomName;
					room.timestamp = `${new Date().getHours()}:${new Date().getMinutes()}`;
					room.iv= fromBinary(res.data.iv)
					room.password=res.data.password
					room.users = [
						{
							_id: userId,
							username: username
						}
					];

					room.avatar = 'https://www.meme-arsenal.com/memes/b6a18f0ffd345b22cd219ef0e73ea5fe.jpg';
					room.index = 0;
					room.lastMessage = {
						height: 0,
						content: 'Stanza creata!',
						//timestamp: formatTimestamp(
						//	new Date(),
						//)
					}
					console.log(this.rooms);
					console.log({room:room.roomId,userId:userId})
					this.$soketio.emit('join', {roomId:room.roomId,userId:userId});
					this.rooms.push(room);
					//this.listenLastMessage(room);
					this.roomsLoadedCount += 1;


					this.roomsLoaded = true
				})
				.catch((error) =>{
					this.ErrorCreateRoom=error.response.data.message
					this.addRoom()

					console.log(error);
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

		// ,incrementDbCounter(type, size) {
		// 	size = size || 1
		// 	this.dbRequestCount += size
		// 	console.log(type, size)
		// }
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