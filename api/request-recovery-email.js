'use strict'

const Isemail = require('isemail')
const jwt = require('jsonwebtoken')
const fs = require('fs')
const nodemailer = require('nodemailer')
const config = require('./config')
const excluded_domain = require('./excluded-domain')

const jwt_key = fs.readFileSync('/jwt/jwt_sync.key')

const transporter = nodemailer.createTransport(config.smtp_config)

const recovery_template = fs.readFileSync('./recovery-template.htm').toString()

// send the desired recovery email via email as JWT
module.exports = (rdb, req, res) => {
  // validate the email
  if(!Isemail.validate(req.body.email) || excluded_domain(req.body.email)){
    res.send({success: false})
  }else{
    // reject if email is already stored
    rdb.get('MFA_RECOVERY_EMAIL:' + req.user.guid.toLowerCase(), (err, reply) => {
      if(reply){
        res.send({success: false})
      }else{
        // generate a JWT
        const token = jwt.sign(
          {
            recovery: true,
            guid: req.user.guid.toLowerCase(),
            email: req.body.email
          },
          jwt_key,
          {
            expiresIn: config.links_expire
          }
        )
        // send an email
        const recovery_body = recovery_template.replace(
          '[JWT Link]', config.base_url + '/api/jwt/' + token
        ).replace(
          '[Support URL]', config.support_url
        )
        const mail_options = {
          from: config.from,
          to: req.body.email,
          subject: config.recovery_verification_subject,
          html: recovery_body
        }
        transporter.sendMail(mail_options, (err, info) => {
          // log that the email was sent
          if(err){
            console.log(err)
            res.send({success: false})
          }else{
            console.log(JSON.stringify(info))
            res.send({success: true})
          }
        })
      }
    })
  }
}
