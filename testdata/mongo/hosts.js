db = db.getSiblingDB('uclogs')
db.hosts.drop()
db.hosts.insert({
  agentId : "476b1ffa-441f-4a17-a126-5c372c74f1c4",
  userId: '542b86ced486e035d39a7a7e', 
  hostname: "mingqi-mac",
  files: [ "/var/tmp/1.log",  "/var/tmp/4.log"],
  lastPushDate: ISODate("2014-05-09T09:09:00Z"),
  version: "1.0.0"
  })
