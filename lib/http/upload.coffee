us = require 'underscore'
moment = require 'moment'

_receive = (record, tag, userId) ->
  record.userId = userId
  return {
    tag: tag
    record: record 
  }

module.exports = handler = (emit, req, res) ->
  tag = req.path[1..]
  try
    record_list = if us.isArray(req.body) then req.body else [req.body]
    for d in us.map(record_list, (record) -> _receive(record, tag, req.userId))
      emit(d)

    res.status(200).send({message: 'success'})
  catch e
    logger.error e
    return res.status(500).send({message: e.message}) 