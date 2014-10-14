logcola = require 'logcola'
elasticsearch = require('elasticsearch')
moment = require 'moment'

###
write data to elastic search index

- hosts
- index
- type

###

module.exports = (config) ->
  hosts = config.hosts

  _client = new elasticsearch.Client
    host: hosts
    log: 'warning'
  _buffer = new logcola.Buffer(config)

  _buffer.writeChunk = (chunk, callback) ->
    bulk_body = []
    for {tag, time, record} in chunk
      timestamp = moment(record.timestamp)
      index_suffix = timestamp.format('YYYYMMDD') 
      bulk_body.push
        index: 
          _index: "uclogs-"+index_suffix, 
          _type: 'event'
          _id: record.uuid

      bulk_body.push {
        timestamp : timestamp.format()
        userId : record.userId
        host: record.host
        path: record.path
        message: record.message         
      }

    logger.info "#{chunk.length} log events is indexing to ES... "
    _client.bulk {body: bulk_body}, (err) ->
      logger.info "#{chunk.length} was indexed by ES"
      callback()
    

  return {

    start : (callback) ->
      callback()

    shutdown : (callback) ->
      _buffer.stop callback
    
    write : (data) ->
      _buffer.write data 

  }
