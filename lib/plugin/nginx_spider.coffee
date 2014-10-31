us = require 'underscore'

SPIDER_MAPPINGS ={
  'baidu' : 'Baiduspider/'
  'baidu-image' : 'Baiduspider-image'
  'baidu-video' : 'Baiduspider-video'
  'baidu-news' : 'Baiduspider-news'
  'baidu-ads' : 'Baiduspider-ads'

  'google' : 'Googlebot/'
  'google-news' : 'Googlebot-News'
  'google-image' : 'Googlebot-Image'
  'google-video' : 'Googlebot-Video'
  'google-ads' : 'AdsBot-Google'

  '360' : '360Spider'
  'sogou' : 'Sogou web spider'
  'soso' : 'Sosospider'
  'bing' : ['msnbot', 'bingbot', 'BingPreview']
}

find_spider = (user_agent) ->

  for name, patterns of SPIDER_MAPPINGS
    patterns = [patterns] if us.isString(patterns)

    return name if us.some patterns, (pattern) ->
      user_agent.indexOf(pattern) >= 0
    
  return null 


module.exports = (config) ->
  
  _this = 

    start : (callback) ->
      callback()
    
    shutdown : (callba) ->
      callback()

    write : ({tag, record}, next) ->
      return next(record) if not record['nginx.user_agent']

      user_agent = record['nginx.user_agent']
      
      spider = find_spider(user_agent)
      if spider
        record['nginx.spider'] = spider 

      next(record)
