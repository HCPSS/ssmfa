'use strict'

const express = require('express')
const ejwt = require('express-jwt')
const jwt = require('jsonwebtoken')
const morgan = require('morgan')
const moment = require('moment-timezone')
const fs = require('fs')
const config = require('./config')
const mfa_status = require('./mfa-status')
const recovery_email = require('./recovery-email')
const request_recovery_email = require('./request-recovery-email')
const request_settings_reset = require('./request-settings-reset')
const accept_jwt = require('./accept-jwt')
const get_enrollment_requests = require('./get-enrollment-requests')
const set_enrollment_request = require('./set-enrollment-request')
const get_reset_requests = require('./get-reset-requests')
const del_reset_request = require('./del-reset-request')

// connect to redis
const redis = require('redis'),
  rdb = redis.createClient({host: 'redis'})

// get client and server keys
const auth_key = fs.readFileSync('/jwt/jwt_auth.pub')
const jwt_key = fs.readFileSync('/jwt/jwt_sync.key')

const app = express()

app.use(express.json())

// require authentication except when submitting a token
app.use(ejwt({secret: auth_key}).unless({path: [/^\/api\/jwt\//, /^\/api\/daemon\//]}))

// add security to separate user and daemon rights
app.use((req, res, next) => {
  if(/\/api\/daemon\//.test(req.path)){
    if(req.get('Authorization')){
      const auth = req.get('Authorization').split(' ')
      if(auth[1]){
        const token = auth[1]
        jwt.verify(token, jwt_key, (err, payload) => {
          if(payload && payload.daemon){
            next()
          }else{
            res.status(401).send('invalid token')
          }
        })
      }else{
        res.status(401).send('invalid token')
      }
    }else{
      res.status(401).send('invalid token')
    }
  }else{
    next()
  }
})

// if there is a guid, show it in the log
morgan.token('user', (req) =>
  (
    req.user && req.user.guid.toLowerCase()
  ) || 'no-auth')
// show the request body in the log
morgan.token('body', (req) => JSON.stringify(req.body))
// show the source IP from the other side of the reverse proxy
morgan.token('forward', (req) => req.headers['x-forwarded-for'])
// Format the date like I like it
morgan.token('date', () => moment().tz(config.tz).format('YYYY-MM-DD HH:mm:ss z'))

// add logging middleware for all requests
app.use(morgan((tokens, req, res) => {
  return [
    tokens.date(),
    tokens['remote-addr'](req, res),
    tokens.forward(req),
    tokens.user(req),
    tokens.method(req, res),
    tokens.url(req, res),
    tokens.status(req, res),
    tokens.res(req, res, 'content-length'), '-',
    tokens['response-time'](req, res), 'ms',
    tokens.body(req),
  ].join(' ')
}))

// send unauthorized if not authenticated
app.use((err, req, res, next) => {
  if (err.name === 'UnauthorizedError') {
    res.status(401).send('invalid token')
  }else{
    next()
  }
})

// Get the status of MFA enrollment
app.get('/api/user/status', (req, res) => {
  mfa_status(rdb, req, res)
})

// Get the user's recovery email address
app.get('/api/user/recoveryEmail', (req, res) => {
  recovery_email(rdb, req, res)
})

// Start process to set recovery email
app.post('/api/user/requestRecoveryEmail', (req, res) => {
  if(req.body.email){
    request_recovery_email(rdb, req, res)
  }else{
    res.status(400).send('Bad Request')
  }
})

// Start process to reset MFA setting
app.post('/api/user/requestMFASettingsReset', (req, res) => {
  if(req.body.reset){
    request_settings_reset(rdb, req, res)
  }else{
    res.status(400).send('Bad Request')
  }
})

// Accept JWT for MFA reset or recovery email verification
app.get('/api/jwt/:jwt', (req, res) => {
  accept_jwt(rdb, req, res)
})

// Get list of all pending enrollment requests
app.get('/api/daemon/enrollmentRequests', (req, res) => {
  get_enrollment_requests(rdb, req, res)
})

// Change the status of enrollment requests
app.post('/api/daemon/enrollmentRequests', (req, res) => {
  if(req.body.guid && req.body.status){
    set_enrollment_request(rdb, req, res)
  }else{
    res.status(400).send('Bad Request')
  }
})

// Get list of all pending MFA settings reset requests
app.get('/api/daemon/resetRequests', (req, res) => {
  get_reset_requests(rdb, req, res)
})

// Change the status of MFA settings reset requests
app.post('/api/daemon/resetRequests', (req, res) => {
  if(req.body.guid && req.body.status && req.body.status === 'complete'){
    del_reset_request(rdb, req, res)
  }else{
    res.status(400).send('Bad Request')
  }
})

// Get additional config settings for daemon
app.get('/api/daemon/config', (req, res) => {
  const search_servers = config.search_servers.split(',')
  res.send({
    SearchServers: search_servers
  })
})

// start API
app.listen(9000, () => console.log('API listening on port 9000'))
