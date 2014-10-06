utils = require '../utils'
mongo = require '../mongodb'

module.exports = (config) ->
  
  return {

    start : (callback) ->
      callback()
    
    shutdown : (callback) ->
      callback()
    
    write : ({record}) ->
      db_record = utils.selectKeys(record, ['agentId', 'hostname','version', 'userId'])
      db_record.lastPushDate = new Date()
      agentColl = mongo.db().collection('hosts')
      agentColl.update(utils.selectKeys(db_record, ['agentId', 'userId']),
        {$set: db_record},
        {upsert : true},
        (err) ->
          logger.error err if err
      )
  }

