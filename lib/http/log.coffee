us = require 'underscore'
moment = require 'moment'

_receive = (data) ->
  for member in ['tag', 'record']
    if !data[member]?
      throw Error "illegal data, absense '#{member}', #{JSON.stringify(data)}"   

  time = null
  if data['time']?
    time = moment(data['time']) 
    if not time.isValid()
      throw Error "illegal timestamp format: #{data['time']}"
  
  result = 
    tag: data.tag
    record: data.record
  result.time = time or moment()
  return result 

module.exports = handler = (emit, req, res) ->
    try
      data = if us.isArray(req.body) then req.body else [req.body]
      for d in us.map(data, _receive)
        emit(d)

      res.status(200).send({message: 'success'})
    catch e
      return res.status(200).send({message: e.message}) 