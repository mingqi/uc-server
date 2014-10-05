hoconfig = require 'hoconfig-js'
logcola = require 'logcola'
us = require 'underscore'

plugin = logcola.plugin
Engine = logcola.engine

conf = hoconfig('./conf/dev.conf')
plugin.setPluginPath('./lib/plugin')

engine = Engine()


us.each conf.input, (input) ->
  engine.addInput plugin(input)

us.each conf.output, (output) ->
  o =  plugin(output)
  engine.addOutput output.match, o

engine.start()