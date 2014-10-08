moment = require 'moment'
logtime = require '../lib/plugin/log_timestamp'

message = "[2014-10-08 15:29:17] | http-bio-8080-exec-35 | 26 | 42.120.160.20 | 0 | /books-web/book/detail.html | id=4876830&"

extracted = logtime.extract(message)

a = logtime.correct(moment(1412753357195), extracted)
console.log "aaaaa"
console.log a