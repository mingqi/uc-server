us = require 'underscore'
moment = require 'moment'

_receive = (data, userId) ->
  for member in ['tag', 'record']
    if !data[member]?
      throw Error "illegal data, absense '#{member}', #{JSON.stringify(data)}"   

  ## convert the time to moment object to verify format
  time = null
  if data['time']?
    time = moment(data['time']) 
    if not time.isValid()
      throw Error "illegal timestamp format: #{data['time']}"
  else
    time = moment()
  
  data.record.userId = userId
  result = 
    tag: data.tag
    time: time.toDate().getTime()
    record: data.record

  return result 

module.exports = handler = (emit, req, res) ->
    try
      data = if us.isArray(req.body) then req.body else [req.body]
      for d in us.map(data, (d) -> _receive(d, req.userId))
        emit(d)

      res.status(200).send({message: 'success'})
    catch e
      return res.status(200).send({message: e.message}) 