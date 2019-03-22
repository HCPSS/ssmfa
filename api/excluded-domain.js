'use strict'

const config = require('./config')

module.exports = email => {
  const domain = email.split('@')[1]
  const excluded_domains = config.excluded_domains.split(',')
  for(let i=0; i < excluded_domains.length; i++){
    const pattern = new RegExp(excluded_domains[i].replace('.', '\\.') + '$')
    if(pattern.test(domain.toLowerCase())){
      return true
    }
  }
  return false
}
