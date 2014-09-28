express = require 'express'
getBody = require 'raw-body'
typeis = require 'type-is'
zlib = require 'zlib'
compression = require 'compression'
us = require 'underscore'

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
  return (req, res, next) ->
    identify  = (callback) ->
      licenseKey = req.get('licenseKey') 
      return callback() if not licenseKey
      users = mongo.db().collection('users')
      users.findOne({licenseKey: licenseKey}, {fields: {_id: 1}}, (err, result) ->
        return callback(err) if err
        return callback(null, null) if not result
        return callback(null, result._id.toString())
      )

    logger.debug "recieve http hit"
    identify((err, result) ->
      if err 
        logger.info("failed to auth request, #{err.message}")
        res.send(500, {message: err.message})
      else if not result
        logger.info("failed to auth request, doesn't have user information")
        res.send(401)
      else
        req.userId = result 
        next()
    )

module.exports = (config) ->
  port = config.port
  bind = config.bind

  app = express()
  # app.use(auth())
  app.use(body())
  app.use(gunzip())
  app.use(json())
  app.use(compression({threshold: false}))

  server = null
    
  _receive = (data) ->
    for member in ['tag', 'record']
      if !data[member]?
        throw Error "illegal data, absense '#{member}', #{JSON.stringify(data)}"   

    if data['time']?
      time = moment(data['time']) 
      if not time.isValid()
        throw Error "illegal timestamp format: #{data['time']}"
    
    result = 
      tag: data.tag
      record: data.record
    result.time = data.time if data.time?

    return result 


  return {
    start : (emit, callback) ->
      app.post '*', (req, res) ->
        try
          data = if us.isArray(req.body) then req.body else [req.body]
          for d in us.map(data, _receive)
            emit(d)

          res.status(200).send({message: 'success'})
        catch e
          return res.status(200).send({message: e.message}) 

      server = app.listen port, bind, callback

    shutdown : (callback) ->
      server.close callback
      
  }

