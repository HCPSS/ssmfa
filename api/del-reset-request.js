'use strict'

module.exports = (rdb, req, res) => {
  const guid = req.body.guid
  const status = req.body.status

  rdb.del('MFA_RESET:' + guid, status)
  res.send({success: true})
}
