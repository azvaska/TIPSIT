require('dotenv').config({path: ".env-node2"});
let lotion = require('lotion')
//ip 172.17.5.10:30092
let app = lotion({
  genesisPath: '/usr/src/app/static_config/genesis.json',
  rpcport: 30093,
  initialState: { messages: [] },
  p2pPort: 30094,
  logTendermint: true,
  keyPath: '/usr/src/app/static_config/priv_validator_key.json',
  peers: ['d17fa25484386173fcaa09f75fc9a00e38212a9c@172.18.5.11:30092'],
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