let { connect } = require('lotion')
let verify = require('merk/verify')

let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: '/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/blockchain-chat/api/genesis.json',
    rpcPort: 30099,
    p2pPort:30098,
    logTendermint: true,
    peers: ["c60e3c5df54039b93001f304dde06bde7edee9a2@172.18.5.10:30094","45b8176bc0cb235e5d5cf758fe4c45f3ba3bc34e@172.18.5.11:30092"]
})


lotionapp.use((state, tx) => {
  console.log("statuss"+":"+JSON.stringify(state));
  console.log(JSON.stringify(tx));

    if (typeof tx.sender === 'string' && typeof tx.message === 'string') {
        state.messages.push({ sender: tx.sender, message: tx.message })
    }
});

  

lotionapp.start(3000).then(async ({ GCI }) => {
   let lc = await connect(null,{nodes:
         [`ws://localhost:30099/websocket`,], genesis: require('/mnt/cestino/backup_robba/ProgrammiSviluppo/TIPSIT/chatroom/blockchain-chat/api/genesis.json')
      })
    console.log(await lc.send({sender:"dico",message:"sksk"}));

    console.log(GCI)
})
