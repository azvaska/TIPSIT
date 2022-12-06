require('dotenv').config({ path: ".env-node1" });
let lotion = require('lotion')
//ip 172.17.5.11:30092
let app = lotion({
  genesisPath: '/usr/src/app/static_config/genesis.json',
  // genesisPath: '/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/blockchain-chat/node/node1/config/genesis.json',
  rpcport: 30090,
  initialState: { messages: [] },
  p2pPort: 30092,
  logTendermint: true,
  // keyPath: '/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/blockchain-chat/node/node1/config/priv_validator_key.json',
  keyPath: '/usr/src/app/static_config/priv_validator_key.json',
  peers: ["e54e41945e037994795f0f67b47835063ed911e9@172.18.5.10:30094"],
  createEmptyBlocks: false
})
app.home = '/usr/src/app/'
app.use((state, tx, chainInfo) => {
  if (typeof tx.senderId === 'string' && typeof tx.content === 'string') {
    state.messages.push({
      _id: tx._id,
      senderId: tx.senderId,
      destinationId: tx.destinationId,
      content: tx.content,
      timestamp: tx.timestamp,
    })
  }
})
app.start().then(appInfo => console.log(appInfo.GCI))
