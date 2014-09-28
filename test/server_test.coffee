logcola = require 'logcola'
in_test = require './in_test'
http = require '../lib/plugin/http'
es = require '../lib/plugin/es'
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
engine.addOutput 'test', es
  hosts: ['localhost:9200']
  index: 'ttt'
  type: 'event'
  buffer_type: 'memory'
  buffer_flush: 3
  buffer_size: 10000
  buffer_queue_size: 100
  concurrency: 1 

engine.start()