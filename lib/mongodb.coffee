us = require 'underscore'
Db = require('mongodb').Db
Server = require('mongodb').Server
uclogsDb = null

exports.init = (host, port, done) ->
  uclogsDb = new Db('uclogs', 
                       new Server(host, port, {auto_reconnect : true}),
                       { w : 0, bufferMaxEntries : 0})
  uclogsDb.open (err, db)->
    throw err  if err
    done()

exports.db = () ->
  return uclogsDb
