uuid = require 'uuid'

module.exports = (config) ->
  
  return {

    start : (callback) ->
      callback()

    shutdown : (callback) ->
      callback()

    write : ({tag, record}, next) ->
      if not record.uuid
        record.uuid = uuid.v4()
        next(record)
  }