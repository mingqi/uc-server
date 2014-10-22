module.exports = (config) ->
 
  _this = 

    start : (callback) ->
      callback()

    shutdown : (callback) ->
      callback()
    
    write : ({tag, record}, next) ->
      if record.message?
        record.message = record.message.replace(/\u001b\[(\d{0,3};)*\d{0,3}m/g,'')
      next(record)

  return _this 