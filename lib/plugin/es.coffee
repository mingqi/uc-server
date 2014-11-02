logcola = require 'logcola'
elasticsearch = require('elasticsearch')
moment = require 'moment'
FastMap = require('collections/fast-map')

###
write data to elastic search index

- hosts
- index
- type

###

OPTIONS_ES_FIELDS = [
  "nginx.remote_address", "nginx.request_uri", "_nginx.request_uri"
  "nginx.response_status", "nginx.response_size", "nginx.referer"
  "_nginx.referer", "nginx.user_agent", "nginx.http_method",
  "nginx.spider"
]

truncate_time = (millsec, truncation_value) ->
  millsec - (millsec % truncation_value)


Uniquer = () ->
  
  map = FastMap()

  return {

    put :  (record, field) ->
      timestamp = truncate_time(record.timestamp, 1000 * 60)
      key = "#{timestamp}:#{record.userId}:#{record.host}:#{record.path}:#{field}"
      value = 
        timestamp : moment(timestamp).format()
        userId: record.userId
        host: record.host
        path: record.path
        attribute: field

      map.set key, value
    
    unique : () ->
      map.values()

  }


module.exports = (config) ->
  hosts = config.hosts

  _client = new elasticsearch.Client
    host: hosts
    log: 'warning'
  _buffer = new logcola.Buffer(config)

  _buffer.writeChunk = (chunk, callback) ->
    uniquer = Uniquer()
    bulk_body = []
    for {tag, time, record} in chunk
      timestamp = moment(record.timestamp)
      index_suffix = timestamp.format('YYYYMMDD') 
      bulk_body.push
        index: 
          _index: "uclogs-"+index_suffix, 
          _type: 'event'
          _id: record.uuid

      es_event = 
        timestamp : timestamp.format()
        userId : record.userId
        host: record.host
        path: record.path
        message: record.message

      for field in OPTIONS_ES_FIELDS
        if record[field]?
          es_event[field] = record[field]

      bulk_body.push es_event

      for field in OPTIONS_ES_FIELDS
        if record[field]?
          uniquer.put record, field

    for attribute in uniquer.unique()
      index_suffix = moment(attribute.timestamp).format('YYYYMMDD')
      bulk_body.push 
        index: 
          _index: "uclogs-"+index_suffix, 
          _type: 'attributes'
      bulk_body.push attribute

    logger.info "#{chunk.length} log events is indexing to ES... "
    _client.bulk {body: bulk_body}, (err) ->
      if err
        logger.error err
        return callback(err)
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
