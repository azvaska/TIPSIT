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
  peers: ["16eab664372ed17a72177cd698371dec67613861@172.18.5.10:30094"],
  createEmptyBlocks: false
})
app.home = '/usr/src/app/'
app.use((state, tx, chainInfo) => {
  if (typeof tx.userId === 'string') {
    state.messages.push({
      _id: tx._id,
      userId: tx.userId,
      roomId: tx.roomId,
      content: tx.content,
      timestamp: tx.timestamp,
    })
  }
})
app.start().then(appInfo => console.log(appInfo.GCI))
