'use strict'

module.exports = (rdb, req, res) => {
  // get all status keys
  rdb.keys('MFA_STATUS:*', (err, reply) => {
    const status_promises = []
    for(let i=0; i < reply.length; i++){
      const key = reply[i]
      const guid = key.split(':')[1]
      status_promises.push(new Promise(resolve => {
        rdb.get(key, (err, reply) => {
          resolve({guid: guid, status: reply})
        })
      }))
    }
    // if there are no promises send nothing
    if(status_promises.length === 0){
      res.send([])
    }else{
      // get only the status keys marked pending
      Promise.all(status_promises).then(replies => {
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
