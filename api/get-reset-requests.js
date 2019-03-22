'use strict'

module.exports = (rdb, req, res) => {
  // get all reset keys
  rdb.keys('MFA_RESET:*', (err, reply) => {
    const reset_promises = []
    for(let i=0; i < reply.length; i++){
      const key = reply[i]
      const guid = key.split(':')[1]
      reset_promises.push(new Promise(resolve => {
        rdb.get(key, (err, reply) => {
          resolve({guid: guid, status: reply})
        })
      }))
    }
    // if there are no promises send nothing
    if(reset_promises.length === 0){
      res.send([])
    }else{
      // get only the reset keys marked pending
      Promise.all(reset_promises).then(replies => {
        const pending = []
        for(let i=0; i < replies.length; i++){
          const reply = replies[i]
          if(reply.status === 'pending'){
            pending.push(reply)
          }
        }
        res.send(pending)
      })
    }
  })
}
