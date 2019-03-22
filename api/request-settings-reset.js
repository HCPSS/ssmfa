'use strict'

const jwt = require('jsonwebtoken')
const fs = require('fs')
const nodemailer = require('nodemailer')
const config = require('./config')

const jwt_key = fs.readFileSync('/jwt/jwt_sync.key')

const transporter = nodemailer.createTransport(config.smtp_config)

const reset_template = fs.readFileSync('./reset-template.htm').toString()

// send token
module.exports = (rdb, req, res) => {
  // get the email from redis
  rdb.get('MFA_RECOVERY_EMAIL:' + req.user.guid.toLowerCase(), (err, reply) => {
    if(reply){
      // generate a JWT
      const token = jwt.sign(
        {
          reset: true,
          guid: req.user.guid.toLowerCase(),
          email: reply
        },
        jwt_key,
        {
          expiresIn: config.links_expire
        }
      )
      // send an email
      const reset_body = reset_template.replace(
        '[JWT Link]', config.base_url + '/api/jwt/' + token
      ).replace(
        '[Support URL]', config.support_url
      )
      const mail_options = {
        from: config.from,
        to: reply,
        subject: config.reset_verification_subject,
        html: reset_body
      }
      transporter.sendMail(mail_options, (err, info) => {
        // log that the email was sent
        console.log(JSON.stringify(info))
        res.send({success: true})
      })
    }else{
      res.send({success: false})
    }
  })
}
