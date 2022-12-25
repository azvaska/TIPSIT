const path_gense = "./genesis.json"


let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: path_gense,
    rpcPort: 30098,
    p2pPort: 30099,
    logTendermint: true,
    peers: ["9b9b902550cffc90729e116389771cd3aa22cede@172.18.5.11:30094","b6dcc72a2631fac1a0816cc0154275bdfca1480e@172.18.5.10:30092"]
})


lotionapp.use((state, tx) => {
    state.messages.push({
        _id: tx._id,
        userId: tx.userId,
        roomId: tx.roomId,
        content: tx.content,
        timestamp: tx.timestamp,
      })
});

lotionapp.start(3000).then(async ({ GCI }) => {
   
})
