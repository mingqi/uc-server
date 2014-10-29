decodeurl = require 'decodeurl'

module.exports = (config) ->
  
  _this = 

    start : (callback) ->
      callback()
    
    shutdown : (callback) ->
      callback()
   
    write : ({tag, record}, next) ->
      if record.message?
        record.message = decodeurl(record.message)
      next(record) 

  return _this

  