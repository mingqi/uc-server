moment = require 'moment'
us = require 'underscore'
assert = require 'assert'
findtime = require 'findtime'



toSameZone = (event_epoch, log_epoch) ->
  diff =  log_epoch - event_epoch
  if Math.abs(diff) > 60 * 60 * 24
    return log_epoch

  step = if diff > 0 then -1800 else 1800
  result = log_epoch
  while not (event_epoch >= result and event_epoch - result < 1800)
    result += step

  return result


correct = (event_timestamp, log_time) ->
  return event_timestamp  if not log_time 

  log_time = us.clone(log_time)

  # fill in missed year, month or day
  if not log_time.year?
    log_time.year = event_timestamp.year()
  if not log_time.month?
    log_time.month = event_timestamp.month() + 1
  if not log_time.day?
    log_time.day = event_timestamp.date()

  # fix month 0-11 to adopt moment 
  log_time.month = log_time.month - 1
  log_epoch = moment(log_time).unix()
  event_epoch = event_timestamp.unix()

  log_epoch = toSameZone(event_epoch, log_epoch)


  # the event_epoch must be greater than log_epoch, toSameZone will guarantee that
  diff = event_epoch - log_epoch
  if diff > 60 * 10
    return event_timestamp
  else
    return moment.unix(event_epoch - diff)

correct_by_zone = (event_timestamp, log_time, zone_offset) ->
  # logger.debug event_timestamp.unix(), log_time, zone_offset
  return event_timestamp  if not log_time 
  log_time = us.clone(log_time)

  # fill in missed year, month or day
  if not log_time.year?
    log_time.year = event_timestamp.year()
  if not log_time.month?
    log_time.month = event_timestamp.month() + 1
  if not log_time.day?
    log_time.day = event_timestamp.date()

  # fix month 0-11 to adopt moment 
  log_time.month = log_time.month - 1
  log_epoch = moment.utc(log_time).unix()
  return moment.unix(log_epoch + (zone_offset * 60))


###
- lookup_key
- timestamp_key
###
module.exports = (config) ->

  parse_key = "message"
  timestamp_key = "timestamp"
  assert.ok(parse_key, 'option parse_key is required for log_timestamp plugin')
  assert.ok(timestamp_key, 'option timestamp_key is required for log_timestamp plugin')
  
  return {

    start : (callback) ->
      callback()

    shutdown : (callback) ->
      callback()

    write : ({tag, time, record}, next) ->
      if not record[timestamp_key]?
        record[timestamp_key] = correct_by_zone(
          moment(record.event_timestamp), 
          findtime(record[parse_key]),
          record.tz_offset 
        ).toDate().getTime()
        next(record)
  }

module.exports.correct = correct