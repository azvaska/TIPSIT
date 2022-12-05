   
   let { connect } = require('lotion')
   let createHash = require('create-hash')
   let LightNode = require('tendermint')
   function stateFromGenesis (genesis) {
      let validators = genesis.validators.map(validator => {
        return Object.assign({}, validator, {
          voting_power: Number(validator.power)
        })
      })
    
      return {
        validators,
        commit: null,
        header: { height: 1, chain_id: genesis.chain_id }
      }
    }

    let vstruct = require('varstruct')
let { stringify, parse } = require('deterministic-json')

let TxStruct = vstruct([
  { name: 'data', type: vstruct.VarString(vstruct.UInt32BE) },
  { name: 'nonce', type: vstruct.UInt32BE }
])

const decode = txBuffer => {
  let decoded = TxStruct.decode(txBuffer)
  let tx = parse(decoded.data)
  return tx
}
const encode = (txData, nonce) => {
  let data = stringify(txData)
  let bytes = TxStruct.encode({ nonce, data })
  return bytes
}

   const sus = async () => {
      // let clientState = stateFromGenesis(require('./genesis.json'))
      // console.log(clientState)
      // let client = LightNode("ws://172.18.5.10:39011/websocket", clientState);
      // console.log(client)
      // function SendTx(lc) {
      //    return function(tx) {
      //      let nonce = Math.floor(Math.random() * (2 << 12))
      //      let txBytes = encode(tx, nonce).toString('base64')
      //      return lc.rpc.broadcastTxCommit({ tx: txBytes })
      //    }
      //  }
      //  console.log(await SendTx(client)({sender:"awaska",message:"sksk"}))
    let { state, send } = await connect(null,{nodes:
         [`ws://172.18.5.11:36943/websocket`,], genesis: require('./genesis.json')
      })
    console.log(await state);
    console.log(await send({sender:"awaska",message:"sksk"}));
   }

    sus();