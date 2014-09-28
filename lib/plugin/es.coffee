logcola = require 'logcola'
elasticsearch = require('elasticsearch')

###
write data to elastic search index

- hosts
- index
- type

###

es = (config) ->
  hosts = config.hosts
  index = config.index
  type = config.type   

  client = new elasticsearch.Client
    host: hosts
    log: 'warning'

  return {
    
    start : (callback) ->
      callback()

    shutdown : (callback) ->
      callback()

    serialize : (data) ->
      return new Buffer(JSON.stringify(data), 'utf-8')
    
    unserialize : (buff) ->
      JSON.parse(buff.toString('utf-8'))

    writeChunk : (chunk, callback) ->
      bulk_body = []
      for {tag, time, record} in chunk
        bulk_body.push 
          index: 
            _index: index, 
            _type: type

        bulk_body.push record

      console.log bulk_body
      client.bulk {body: bulk_body}, (err, res) ->
        console.log err
        console.log res
      

  }

module.exports = (config) -> 
  logcola.buffer(config, es(config))
