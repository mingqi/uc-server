db = db.getSiblingDB('uclogs')
db.hosts.drop()
db.hosts.insert({
  agentId : "agent001",
  userId: '542b86ced486e035d39a7a7e', 
  hostname: "es-dev-01",
  files: [ "/var/logs/web.log",  "/var/logs/app.log",  "/var/logs/apache.log"],
  lastPushDate: ISODate("2014-05-09T09:09:00Z"),
  version: "1.0.0"
  })
