
Server = require '../lib/cli/server'

serv = new Server()
serv.setLogger console
serv.start()
