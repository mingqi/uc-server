moment = require 'moment'
us = require 'underscore'
assert = require 'assert'

###
  auto find timestamp from log line

  - rails format: 2014-07-24T10:14:13.789917
  - syslog: Sep 29 06:33:21
  - log4j:
      DEFAULT: 2012-11-02 14:34:02,781
      ISO8601: 2012-11-02T14:34:02,781
      ISO8601_BASIC: 20121102T143402,781
      ABSOLUTE: 14:34:02,781
      DATE: 02 Nov 2012 14:34:02,781
      COMPACT: 20121102143402781
      UNIX: 1351866842
      UNIX_MILLIS: 1351866842781
  - nginx: 2014/09/29 12:05:34
  - apache acess: 10/Oct/2000:13:55:36 -0700
  - apache error: Fri Dec 16 01:46:23 2005

###

MONTHS_REGEXP = 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'
MONTHS =
  Jan: 1
  Feb: 2
  Mar: 3
  Apr: 4
  May: 5
  Jun: 6
  Jul: 7
  Aug: 8
  Sep: 9
  Oct: 10
  Nov: 11
  Dec: 12

syslog = 
  ## apache error also comply with whit pattern
  ## Sep 29 06:33:21
  regexp : new RegExp("(#{MONTHS_REGEXP})\\s+(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")

  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      month: MONTHS[r[i+=1]]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

standard =
  ## 2012-11-02 14:34:02
  regexp : new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

iso8601 = 
  ## 2012-11-02T14:34:02
  regexp : new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})T(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

absolute =
  ## 14:34:02,781
  regexp : new RegExp('(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }  

nginx = 
  ##  2014/09/29 12:05:34
  regexp : new RegExp('(20\\d{2})/(\\d{1,2})/(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }  

apache =
  ## 10/Oct/2000:13:55:36
  regexp : new RegExp("(\\d{1,2})/(#{MONTHS_REGEXP})/(20\\d{1,2}):(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      day: r[i+=1]
      month: MONTHS[r[i+=1]]
      year: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

date = 
  ## 02 Nov 2012 14:34:02
  regexp : new RegExp("(\\d{1,2})\\s+(#{MONTHS_REGEXP})\\s+(20\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      day: r[i+=1]
      month: MONTHS[r[i+=1]]
      year: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

iso8601_basic = 
  ## 20121102T143402
  regexp : new RegExp("(20\\d{2})(\\d{2})(\\d{2})T(\\d{2})(\\d{2})(\\d{2})")   
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

patterns = [
  standard  # 2012-11-02 14:34:02
  iso8601   # 2012-11-02T14:34:02
  date      # 02 Nov 2012 14:34:02
  syslog    # Sep 29 06:33:21
  nginx     # 2014/09/29 12:05:34
  apache    # 10/Oct/2000:13:55:36
  absolute  # 14:34:02
  iso8601_basic # 20121102T143402
]


extract = (str, prefer) ->
  for p in patterns
    if p.regexp.test(str)
      r = {}
      for k, v of p.parse(str)
        r[k] = parseInt(v)
      return r

  return null

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
        record[timestamp_key] = correct(moment(record.event_timestamp), extract(record[parse_key])).toDate().getTime()
        next(record)
  }

module.exports.extract = extract
module.exports.correct = correct