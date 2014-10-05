a = (ar) ->
  setTimeout () ->
    console.log ar
  , 2000
  
  
b = [1,2,3]
a(b)
b = []