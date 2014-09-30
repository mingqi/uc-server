moment = require 'moment'
logcola = require 'logcola'

log_timestamp = require '../lib/plugin/log_timestamp'

in_test = () ->
  
  return {

    start : (emit, callback) ->
      event_time = moment()
      log_time = event_time.clone().add(15, 'second')
      emit
        tag: 'test'
        time: event_time
        record:
          message : "[#{log_time.format()}] helloworkd"
    
    shutdown : (callback) ->
      callback()      

  }

output = logcola.plugins.chain({output :[
  log_timestamp({timestamp_key:'tttt', lookup_key:'message'})
  logcola.plugins.stdout()
  ]})

engine = logcola.engine()
engine.addOutput 'test', output
engine.addInput(in_test())

engine.start()