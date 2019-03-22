'use strict'

// send the status of the user; pending, enabled, or disabled
module.exports = (rdb, req, res) => {
  rdb.get('MFA_STATUS:' + req.user.guid.toLowerCase(), (err, reply) => {
    if(reply && (reply === 'pending' || reply === 'enabled')){
      res.send({status: reply})
    }else{
      res.send({status: 'disabled'})
    }
  })
}
