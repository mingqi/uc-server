
###
$remote_addr - $remote_user [$time_local] 
"$request” $status $body_bytes_sent 
"$http_referer” "$http_user_agent"
###
nginx_default = (str) ->

  r = ///^
    ([^\s]+)\s+         # remote_addrss
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
  return {
    remote_addrss: m[1]
    request_uri: m[5]
    response_status: parseInt(m[6])
    response_size: parseInt(m[7])
    referer: m[8]
    user_agent: m[9]
  }
 
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
        nginx = pattern(record.message)
        break if nginx 

      if nginx
        for k,v of nginx
          record["nginx.#{k}"] = v
          if k in search_field
            record["_nginx.#{k}"] = v

      next(record) 

  return _this