logcola = require 'logcola'
in_test = require './in_test'
http = require '../lib/plugin/http'
log4js = require 'log4js'

engine = logcola.engine()

global.logger = log4js.getLogger('server_test')


# engine.addInput(in_test
#   tag: 'test'
#   interval: 1
#   monitor: 'mm'
# )

engine.addInput http
  port: 8010
  bind: '0.0.0.0'

 
engine.addOutput 'test', logcola.plugins.stdout()

engine.start()