db = db.getSiblingDB('uclogs')
db.users.drop()
db.users.insert({
  "_id" : ObjectId("542b86ced486e035d39a7a7e"),
  "email" : "blogbbs@gmail.com", 
  "passwordMd5" : "362977b0466a8317693d7da03fb2a7d3", 
  "licenseKey" : "lzyJanDTLW4yQ4nNKd3t", 
  "roles" : [ ]
})