mongo = require('../mongodb')
us = require 'underscore'

handler = (req, res) ->
  result = []
  userId = req.userId
  agentId = req.params.agentId
  hostColl = mongo.db().collection('hosts')
  hostColl.findOne {userId: userId, agentId: agentId}, {fields: {files: 1}}, (err, result) ->
    res.send(result.files)

module.exports = handler