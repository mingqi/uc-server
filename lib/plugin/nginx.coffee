validator = require 'validator'


###
$remote_addr - $remote_user [$time_local] 
"$request” $status $body_bytes_sent 
"$http_referer” "$http_user_agent"
###
nginx_default = (str) ->

  r = ///^
    ([^\s]+)\s+         # remote_address
    ([^\s]+)\s+         #  -
    ([^\s]+)\s+         # remote_user
    \[([^\[\]]+)\]\s+   # time_local
    "([^"]+)"\s+        # request
    (\d+)\s+            # status
    (\d+)\s+            # body_bytes_sent
    "([^"]+)"\s+        # http_referer”
    "([^"]+)"           # user_agent
  ///
  
  m = r.exec(str) 
  return null if not m

  request_uri = m[5]
  sp = request_uri.split(/\s+/)
  return null if sp.length != 3
  return null if sp[0] not in ['GET', 'POST', 'HEAD', 'PUT', 'DELETE', 'TRACE', 'CONNECT']

  return {
    remote_address: m[1]
    http_method: sp[0]
    request_uri: sp[1]
    response_status: parseInt(m[6])
    response_size: parseInt(m[7])
    referer: m[8]
    user_agent: m[9]
  }

validate_nginx = (nginx) ->
  if nginx.response_status?
    return false if nginx.response_status < 100 or nginx.response_status >=600

  if nginx.remote_address?
    return false if not validator.isIP(nginx.remote_address)

  return true

 
patterns = [ nginx_default ]

module.exports = (config) ->
  
  _this = 

    start : (callback) ->
      callback()
    
    shutdown : (callback) ->
      callback()
   
    write : ({tag, record}, next) ->
      search_field = ['request_uri', 'referer']
      nginx = null
      for pattern in patterns
        n = pattern(record.message)
        if n and validate_nginx(n)
          nginx = n
          break

      if nginx
        for k,v of nginx
          record["nginx.#{k}"] = v
          if k in search_field
            record["_nginx.#{k}"] = v

      next(record) 

  return _this