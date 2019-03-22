'use strict'

module.exports = (rdb, req, res) => {
  const guid = req.body.guid
  const status = req.body.status

  rdb.set('MFA_STATUS:' + guid, status)
  res.send({success: true})
}
