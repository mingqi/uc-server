us = require 'underscore'

utils = {}

utils.selectKeys = (obj, keys) ->
  result = {}
  for key in keys
    result[key] = obj[key] if obj[key]?
  result

module.exports = utils