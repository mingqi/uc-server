logcola = require 'logcola'
sys = require 'moment'
path = require 'path'
moment = require 'moment'


File = logcola.plugins.File

module.exports = (config) ->

  file = File(config)
  file.path = (data) ->
    p = path.join config.path
    , data.record.userId
    , moment(data.record.timestamp).format('YYYY/MM/DD/HH') + ".log"

    return p

  return file