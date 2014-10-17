hoconfig = require 'hoconfig-js'
logcola = require 'logcola'
us = require 'underscore'
program = require 'commander'
path = require 'path'
log4js = require 'log4js'


mongo = require './lib/mongodb'

plugin = logcola.plugin
Engine = logcola.Engine

program
  .option('-c, --config [path]', 'config file')
  .parse(process.argv)

if not program.config
  program.help()

settings = hoconfig(program.config)
log4js.configure(settings.log4js)
global.logger = log4js.getLogger('uc-server')

logger.info "setting is #{JSON.stringify settings, null, 4}"
logcola_path = path.join(path.dirname(program.config),settings.logcola.conf)

plugin_path = path.resolve(path.join(path.dirname(program.config),settings.logcola.plugin))

conf = hoconfig(logcola_path)
logger.info "logcola configuration is #{JSON.stringify conf, null, 4}"
plugin.setPluginPath(plugin_path)

engine = Engine()

us.each conf.input, (input) ->
  engine.addInput plugin(input)

us.each conf.output, (output) ->
  o =  plugin(output)
  engine.addOutput output.match, o

mongo.init settings.mongo.host, settings.mongo.port, (err, done) ->
  throw err if err
  engine.start (err) ->
    throw err if err
    logger.info "us-server started"
  
  