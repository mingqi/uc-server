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

    serialize : (data) ->
      data.record.timestamp = data.record.timestamp.format()
      return new Buffer(JSON.stringify(data), 'utf-8')
    
    unserialize : (buff) ->
      r = JSON.parse(buff.toString('utf-8'))
      r.record.timestamp = moment(r.record.timestamp)
      return r

    writeChunk : (chunk, callback) ->
      bulk_body = []
      for {tag, time, record} in chunk
        index_suffix = record.timestamp.format('YYYYMMDD') 
        bulk_body.push
          index: 
            _index: "uclogs-"+index_suffix, 
            _type: 'event'

        bulk_body.push {
          timestamp : record.timestamp.format()
          userId : record.userId
          host: record.host
          path: record.path
          message: record.message         
        }

      logger.debug "elasticsearch bulk:"
      logger.debug bulk_body
      _client.bulk {body: bulk_body}, callback
  }

module.exports = (config) -> 
  logcola.buffer(config, es(config))
