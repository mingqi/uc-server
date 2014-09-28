elasticsearch = require('elasticsearch')

client = new elasticsearch.Client
  host: ['localhost:9200']
  log: 'info'

bulk_body = [
  { index: { _index: 'ttt', _type: 'event' } },
  { name: 'mingqi' },
  { index: { _index: 'ttt', _type: 'event' } },
  { name: 'xulei' } 
]

client.bulk bulk_body, (err, res) ->
  console.log err
  console.log res