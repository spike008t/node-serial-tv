
Client = require '../lib/cli/client'

cli = new Client()
cli.setLogger console
cli.start()
