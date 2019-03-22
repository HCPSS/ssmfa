'use strict'

const jwt = require('jsonwebtoken')
const fs = require('fs')
const config = require('./config')

// get the server key
const jwt_key = fs.readFileSync('/jwt/jwt_sync.key')

const api_key = jwt.sign({daemon: true}, jwt_key)

console.log('Base URL: ' + config.base_url)
console.log('API Key: ' + api_key)
console.log('Run Setup.ps1 on the windows system')
