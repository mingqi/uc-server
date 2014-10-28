FastSet = require('collections/fast-set')
FastMap = require('collections/fast-map')

map = FastMap()
map.set('123', {"name": '123'})
map.set('123', {"name": '456'})
map.set('321', {"name": '321'})
console.log map.length

console.log map.values()

