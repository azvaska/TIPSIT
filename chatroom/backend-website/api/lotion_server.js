const path_gense = "./genesis.json"


let lotionapp = require('lotion')({
    initialState: { messages: [] },
    genesisPath: path_gense,
    rpcPort: 30098,
    p2pPort: 30099,
    logTendermint: true,
    peers: ["39cf935eb23539af6506d3f5cdfbcc7af602bdb9@138.3.243.70:30094","8f08150f9c1300af4d8b4bccd7a0c1e2be5c6895@138.3.243.70:30092"]
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
