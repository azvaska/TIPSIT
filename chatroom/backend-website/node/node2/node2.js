let lotion = require('lotion')
//ip 172.17.5.10:30092
let app = lotion({
  genesisPath: '/usr/src/app/static_config/genesis.json',
  rpcport: 30093,
  initialState: { messages: [] },
  p2pPort: 30094,
  logTendermint: true,
  keyPath: '/usr/src/app/static_config/priv_validator_key.json',
  peers: ['ff12b6e5e47b47002494149a963dd10f1e92a4c8@172.18.5.11:30092'],
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
