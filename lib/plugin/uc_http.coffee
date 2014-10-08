express = require 'express'
getBody = require 'raw-body'
typeis = require 'type-is'
zlib = require 'zlib'
compression = require 'compression'
us = require 'underscore'

uploadHandler = require '../http/upload'
configHandler = require '../http/config'
mongo = require '../mongodb'

###
  http input plugin. accept http request.

- port
- bind
###


body = () ->
  return (req, res, next) ->
    getBody(req, null, (err, result) ->
      req.body = result
      return next(err)
    )

gunzip = () ->
  return (req, res, next) ->
    encoding = req.get('Content-Encoding')
    if encoding == 'gzip' and req.body?
      zlib.gunzip(req.body, (err, result) ->
        req.body = result    
        next(err)
      )
    else
      next()

json = () ->
  return (req, res, next) ->
    if not req.body?
      return next()
    if not typeis(req, 'json')
      return next()

    if req.body instanceof String
      str = req.body
    else if req.body instanceof Buffer
      str = req.body.toString()
    else
      throw new TypeError("req.body should be String or Buffer")

    req.body = JSON.parse(str)
    next()

auth = () ->
  _cache = {}
  return (req, res, next) ->
    identify  = (callback) ->
      licenseKey = req.get('licenseKey') 
      if _cache[licenseKey]
        return callback(null, _cache[licenseKey])

      return callback() if not licenseKey
      users = mongo.db().collection('users')
      users.findOne({licenseKey: licenseKey}, {fields: {_id: 1}}, (err, result) ->
        return callback(err) if err
        return callback(null, null) if not result

        _cache[licenseKey] = result._id.toString()
        return callback(null, _cache[licenseKey])
      )

    logger.debug "recieve http hit"

    identify((err, result) ->
      if err 
        logger.info("failed to auth request, #{err.message}")
        res.status(500).send({message: err.message})
      else if not result
        logger.info("failed to auth request, doesn't have user information")
        res.status(401).end()
      else
        req.userId = result 
        next()
    )

module.exports = (config) ->
  port = config.port
  bind = config.bind

  app = express()
  app.use(auth())
  app.use(body())
  app.use(gunzip())
  app.use(json())
  app.use(compression({threshold: false}))

  server = null
    
  return {
    
    start : (emit, callback) ->
      app.post '*', (req, res) ->
        uploadHandler(emit, req, res)

      app.get '/config/:agentId', configHandler

      server = app.listen port, bind, callback

    shutdown : (callback) ->
      server.close callback
      
  }

