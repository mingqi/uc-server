us = require 'underscore'
async = require 'async'

utils = require '../utils'
mongo = require '../mongodb'

handler = (req, res) ->
  acceptReq = () ->
    if us.isArray(req.body)
      req.body
    else
      [req.body]

  procssAgent = (agent, callback) ->
    db_record = utils.selectKeys(agent, ['agentId', 'hostname','version'])
    db_record.userId= req.userId
    db_record.lastPushDate = new Date()
    agentColl = mongo.db().collection('hosts')
    agentColl.update(utils.selectKeys(db_record, ['agentId', 'userId']),
      {$set: db_record},
      {upsert : true},
      callback
    )
    

  end = (err) ->
    res.send(JSON.stringify({result: 'success'})) 

  async.eachSeries(
    acceptReq()
    procssAgent,      
    end 
  )

module.exports = handler
