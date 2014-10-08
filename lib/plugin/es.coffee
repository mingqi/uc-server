logcola = require 'logcola'
elasticsearch = require('elasticsearch')
moment = require 'moment'

###
write data to elastic search index

- hosts
- index
- type

###

es = (config) ->
  hosts = config.hosts

  _client = null

  return {
    
    start : (callback) ->
      _client = new elasticsearch.Client
        host: hosts
        log: 'warning'
      callback()

    shutdown : (callback) ->
      callback()

    writeChunk : (chunk, callback) ->
      bulk_body = []
      for {tag, time, record} in chunk
        timestamp = moment(record.timestamp)
        index_suffix = timestamp.format('YYYYMMDD') 
        bulk_body.push
          index: 
            _index: "uclogs-"+index_suffix, 
            _type: 'event'

        bulk_body.push {
          timestamp : timestamp.format()
          userId : record.userId
          host: record.host
          path: record.path
          message: record.message         
        }

      logger.debug "elasticsearch bulk index #{chunk.length} log events"
      _client.bulk {body: bulk_body}, callback
  }

module.exports = (config) -> 
  logcola.Buffer(config, es(config))
