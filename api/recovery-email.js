'use strict'

// send the recovery email or false
module.exports = (rdb, req, res) => {
  rdb.get('MFA_RECOVERY_EMAIL:' + req.user.guid.toLowerCase(), (err, reply) => {
    if(reply){
      res.send({email: reply})
    }else{
      res.send({email: false})
    }
  })
}
