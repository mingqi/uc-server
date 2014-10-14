db = db.getSiblingDB('uclogs')
db.hosts.drop()
db.hosts.insert({
  agentId : "c6f07d4b-ac8e-41e7-bf1f-9e47dee8da33",
  userId: '542b86ced486e035d39a7a7e', 
  hostname: "mingqi-mac",
  files: [ "/var/tmp/1.log",  "/var/tmp/4.log"],
  lastPushDate: ISODate("2014-05-09T09:09:00Z"),
  version: "1.0.0"
  })
