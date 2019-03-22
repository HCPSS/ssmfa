'use strict'

const jwt = require('jsonwebtoken')
const fs = require('fs')

const jwt_key = fs.readFileSync('/jwt/jwt_sync.key')

const error_message = 'Expired or invalid token. Please continue <a href="/">here</a>.'

module.exports = (rdb, req, res) => {
  const token = req.params.jwt
  jwt.verify(token, jwt_key, (err, payload) => {
    if(!payload){
      res.send(error_message)
    }else if(payload.recovery && payload.guid && payload.email){
      // store recovery email and initiate MFA enrollment
      rdb.set('MFA_RECOVERY_EMAIL:' + payload.guid, payload.email)
      rdb.set('MFA_STATUS:' + payload.guid, 'pending')
      res.redirect('/continue')
    }else if(payload.reset && payload.guid){
      // initiate MFA settings reset
      rdb.set('MFA_RESET:' + payload.guid, 'pending')
      res.redirect('/continue')
    }else{
      res.send(error_message)
    }
  })
}
