<template>
	<div class="window-container" :class="{ 'window-mobile': isDevice }">
		<form v-if="addNewRoom" @submit.prevent="createRoom">
			<input v-model="addRoomUsername" type="text" placeholder="Add username" />
			<button type="submit" :disabled="disableForm || !addRoomUsername">
				Create Room
			</button>
			<button class="button-cancel" @click="addNewRoom = false">Cancel</button>
		</form>
		<chat-window :height="screenHeight" :theme="theme" :styles="styles" :current-user-id="currentUserId"
			:room-id="roomId" :rooms="loadedRooms" :loading-rooms="loadingRooms" :messages="messages"
			:messages-loaded="messagesLoaded" :rooms-loaded="roomsLoaded" :room-actions="roomActions"
			:menu-actions="menuActions" :message-selection-actions="messageSelectionActions" :room-message="roomMessage"
			:templates-text="templatesText" @fetch-more-rooms="fetchMoreRooms" @fetch-messages="fetchMessages"
			@send-message="sendMessage" @edit-message="editMessage" @delete-message="deleteMessage"
			@open-file="openFile" @open-user-tag="openUserTag" @add-room="addRoom"
			@room-action-handler="menuActionHandler" @menu-action-handler="menuActionHandler"
			@message-selection-action-handler="messageSelectionActionHandler"
			@send-message-reaction="sendMessageReaction" @typing-message="typingMessage">
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
			addRoomUsername: '',
			inviteRoomId: null,
			invitedUsername: '',
			removeRoomId: null,
			removeUserId: '',
			removeUsers: [],
			roomActions: [
				//{ name: 'inviteUser', title: 'Invite User' },
				//{ name: 'removeUser', title: 'Remove User' },
				{ name: 'deleteRoom', title: 'Delete Room' }
			],
			menuActions: [
				//{ name: 'inviteUser', title: 'Invite User' },
				//{ name: 'removeUser', title: 'Remove User' },
				{ name: 'deleteRoom', title: 'Delete Room' }
			],
			messageSelectionActions: [{ name: 'deleteMessages', title: 'Delete' }],
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
		this.$soketio.on('new-message', (data) => {
			console.log(data)
			this.fetchRooms();
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
				this.fetchedMessages.forEach(msg => {
					let senderId = msg.senderId;
					let destinationId = msg.destinationId;

					let userId;
					if (senderId == this.currentUserId) userId = destinationId;
					else userId = senderId;

					if (uu.find(element => element == userId) == undefined) {
						uu.push(userId);
					}
				})

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
				let senderId = msg.senderId;
				let destinationId = msg.destinationId;

				let userId;
				if (senderId == this.currentUserId) userId = destinationId;
				else userId = senderId;

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
			const message = {
				sender_id: this.currentUserId,
				content,
				timestamp: Math.floor(new Date().getTime() / 1000)
			}

			if (files) {
				files = null;
			}

			axios.post("http://localhost:3080/api/send", {
				senderId: message.sender_id,
				content: message.content,
				destinationId: roomId
			})
				.then((response) => {
					console.log(response.data.message);
				})

			let date = new Date(message.timestamp * 1000)
			for (let i = 0; i < this.rooms.length; i++) {
				if (this.rooms[i].roomId == roomId) {
					this.rooms[i].lastMessage.content = message.content;
					this.rooms[i].lastMessage.timestamp = `${date.getHours()}:${date.getMinutes()}`;
				}
			}
		},
		/*
				async editMessage({ messageId, newContent, roomId, files }) {
					const newMessage = { edited: new Date() }
					newMessage.content = newContent
		
					if (files) {
						newMessage.files = this.formattedFiles(files)
					} else {
						newMessage.files = firestoreService.deleteDbField
					}
		
					await firestoreService.updateMessage(roomId, messageId, newMessage)
		
					if (files) {
						for (let index = 0; index < files.length; index++) {
							if (files[index]?.blob) {
								await this.uploadFile({ file: files[index], messageId, roomId })
							}
						}
					}
				},
		
				async deleteMessage({ message, roomId }) {
					await firestoreService.updateMessage(roomId, message._id, {
						deleted: new Date()
					})
		
					const { files } = message
		
					if (files) {
						files.forEach(file => {
							storageService.deleteFile(this.currentUserId, message._id, file)
						})
					}
				},
		
				async uploadFile({ file, messageId, roomId }) {
					return new Promise(resolve => {
						let type = file.extension || file.type
						if (type === 'svg' || type === 'pdf') {
							type = file.type
						}
		
						storageService.listenUploadImageProgress(
							this.currentUserId,
							messageId,
							file,
							type,
							progress => {
								this.updateFileProgress(messageId, file.localUrl, progress)
							},
							_error => {
								resolve(false)
							},
							async url => {
								const message = await firestoreService.getMessage(roomId, messageId)
		
								message.files.forEach(f => {
									if (f.url === file.localUrl) {
										f.url = url
									}
								})
		
								await firestoreService.updateMessage(roomId, messageId, {
									files: message.files
								})
								resolve(true)
							}
						)
					})
				},
		
				updateFileProgress(messageId, fileUrl, progress) {
					const message = this.messages.find(message => message._id === messageId)
		
					if (!message || !message.files) return
		
					message.files.find(file => file.url === fileUrl).progress = progress
					this.messages = [...this.messages]
				},
		
				formattedFiles(files) {
					const formattedFiles = []
		
					files.forEach(file => {
						const messageFile = {
							name: file.name,
							size: file.size,
							type: file.type,
							extension: file.extension || file.type,
							url: file.url || file.localUrl
						}
		
						if (file.audio) {
							messageFile.audio = true
							messageFile.duration = file.duration
						}
		
						formattedFiles.push(messageFile)
					})
		
					return formattedFiles
				},
		
				openFile({ file }) {
					window.open(file.file.url, '_blank')
				},
		
				async openUserTag({ user }) {
					let roomId
		
					this.rooms.forEach(room => {
						if (room.users.length === 2) {
							const userId1 = room.users[0]._id
							const userId2 = room.users[1]._id
							if (
								(userId1 === user._id || userId1 === this.currentUserId) &&
								(userId2 === user._id || userId2 === this.currentUserId)
							) {
								roomId = room.roomId
							}
						}
					})
		
					if (roomId) {
						this.roomId = roomId
						return
					}
		
					const query1 = await firestoreService.getUserRooms(
						this.currentUserId,
						user._id
					)
		
					if (query1.data.length) {
						return this.loadRoom(query1)
					}
		
					const query2 = await firestoreService.getUserRooms(
						user._id,
						this.currentUserId
					)
		
					if (query2.data.length) {
						return this.loadRoom(query2)
					}
		
					const users =
						user._id === this.currentUserId
							? [this.currentUserId]
							: [user._id, this.currentUserId]
		
					const room = await firestoreService.addRoom({
						users: users,
						lastUpdated: new Date()
					})
		
					this.roomId = room.id
					this.fetchRooms()
				},
		
				async loadRoom(query) {
					query.forEach(async room => {
						if (this.loadingRooms) return
						await firestoreService.updateRoom(room.id, { lastUpdated: new Date() })
						this.roomId = room.id
						this.fetchRooms()
					})
				},
				*/
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
		/*
		messageSelectionActionHandler({ action, messages, roomId }) {
			switch (action.name) {
				case 'deleteMessages':
					messages.forEach(message => {
						this.deleteMessage({ message, roomId })
					})
			}
		},
	
		async sendMessageReaction({ reaction, remove, messageId, roomId }) {
			firestoreService.updateMessageReactions(
				roomId,
				messageId,
				this.currentUserId,
				reaction.unicode,
				remove ? 'remove' : 'add'
			)
		},
	
		typingMessage({ message, roomId }) {
			if (roomId) {
				if (message?.length > 1) {
					this.typingMessageCache = message
					return
				}
	
				if (message?.length === 1 && this.typingMessageCache) {
					this.typingMessageCache = message
					return
				}
	
				this.typingMessageCache = message
	
				firestoreService.updateRoomTypingUsers(
					roomId,
					this.currentUserId,
					message ? 'add' : 'remove'
				)
			}
		},
	
		async listenRooms(query) {
			const listener = firestoreService.listenRooms(query, rooms => {
				// this.incrementDbCounter('Listen Rooms Typing Users', rooms.length)
				rooms.forEach(room => {
					const foundRoom = this.rooms.find(r => r.roomId === room.id)
					if (foundRoom) {
						foundRoom.typingUsers = room.typingUsers
						foundRoom.index = room.lastUpdated.seconds
					}
				})
			})
			this.roomsListeners.push(listener)
		},
	
		listenUsersOnlineStatus(rooms) {
			rooms.forEach(room => {
				room.users.forEach(user => {
					const listener = firebaseService.firebaseListener(
						firebaseService.userStatusRef(user._id),
						snapshot => {
							if (!snapshot || !snapshot.val()) return
	
							const lastChanged = formatTimestamp(
								new Date(snapshot.val().lastChanged),
								new Date(snapshot.val().lastChanged)
							)
	
							user.status = { ...snapshot.val(), lastChanged }
	
							const roomIndex = this.rooms.findIndex(
								r => room.roomId === r.roomId
							)
	
							this.rooms[roomIndex] = room
							this.rooms = [...this.rooms]
						}
					)
					this.roomsListeners.push(listener)
				})
			})
		},
		*/
		addRoom() {
			console.log("addRoom");
			this.resetForms();
			this.addNewRoom = true;
		},

		async createRoom() {
			console.log("createRoom");
			this.disableForm = true

			axios.post('http://localhost:3080/api/getUser', qs.stringify({
				userId: this.addRoomUsername
			}))
				.then((res) => {
					console.log(res.data);
					if (res.data.error) {
						console.log("non trovato");
						return;
					}
					let userId = res.data.userId;
					let username = res.data.username;

					const roomList = [];

					let room = {};
					room.roomId = userId;
					room.roomName = username;
					room.timestamp = `${new Date().getHours()}:${new Date().getMinutes()}`;

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
					roomList.push(room);
					this.rooms = this.rooms.concat(roomList);
					//this.listenLastMessage(room);
					this.roomsLoadedCount += 1;

					console.log(this.rooms);

					this.roomsLoaded = true
				})
				.catch(function (error) {
					console.log(error);
				})

			this.addNewRoom = false
			this.addRoomUsername = ''
			//this.fetchRooms()
		},
		/*
		inviteUser(roomId) {
			this.resetForms()
			this.inviteRoomId = roomId
		},
	
		async addRoomUser() {
			this.disableForm = true
	
			const { id } = await firestoreService.addUser({
				username: this.invitedUsername
			})
			await firestoreService.updateUser(id, { _id: id })
	
			await firestoreService.addRoomUser(this.inviteRoomId, id)
	
			this.inviteRoomId = null
			this.invitedUsername = ''
			this.fetchRooms()
		},
	
		removeUser(roomId) {
			this.resetForms()
			this.removeRoomId = roomId
			this.removeUsers = this.rooms.find(room => room.roomId === roomId).users
		},
	
		async deleteRoomUser() {
			this.disableForm = true
	
			await firestoreService.removeRoomUser(
				this.removeRoomId,
				this.removeUserId
			)
	
			this.removeRoomId = null
			this.removeUserId = ''
			this.fetchRooms()
		},
		*/
		/*
		async deleteRoom(roomId) {
			const room = this.rooms.find(r => r.roomId === roomId)
	
	
			firestoreService.getMessages(roomId).then(({ data }) => {
				data.forEach(message => {
					firestoreService.deleteMessage(roomId, message.id)
					if (message.files) {
						message.files.forEach(file => {
							storageService.deleteFile(this.currentUserId, message.id, file)
						})
					}
				})
			})
	
			await firestoreService.deleteRoom(roomId)
	
			this.fetchRooms()
		},
	*/
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