
require 'colors'

shell = require 'simple-shell'

Samsung = require '../client/samsungv2'
Lg = require '../client/lg'

TcpConnector = require '../connector/tcp'

class ClientCli

  constructor: ->
    @client = null
    @connector = null
    @shell = shell
    @logger = null

  setLogger: (logger) ->
    @logger = logger

  setEmulator: (emulator) ->
    @emulator = emulator
    @

  getEmulator: ->
    @emulator

  setConnector: (connector) ->
    @connector = connector
    @

  getConnector: () ->
    @connector

  initShell: ->
    shellOps = {
      name: "node-tv-client"
      exitMessage: "End of the client"
      prompt: "node TV client"
    }
    @shell.initialize shellOps

  initCommands: ->
    cmds = [
      {
        name: "create"
        help: "Create a TV client"
        isAvailable: (ctx) =>
          @cmdCreateAvailable ctx
        options: {
          class: {
            help: "Select your TV brand to emulate. Values possible: samsung, lg"
            required: true
            allowedValues: [ "samsung", "lg" ]
          }
        }
        handler: (cmd, opts, ctx) =>
          @cmdCreateHandler cmd, opts, ctx
      }
      {
        name: "connector"
        help: "Select the connector to use"
        isAvailable: (ctx) =>
          @cmdCreateConnectorAvaiable ctx
        options: {
          class: {
            help: "Select the connector to use. Values possible: tcp, fifo, serial"
            required: true
            allowedValues: [ 'tcp', 'fifo', 'serial' ]
          }
          ip: {
            help: "The ip parameter"
          }
          port: {
            help: "The port parameter"
          }
        }
        handler: (cmd, opts, ctx) =>
          @cmdCreateConnector cmd, opts, ctx
      }
      {
        name: "start"
        help: "Start the client"
        isAvailable: (ctx) ->
          @emulator != null && @connector != null
        handler: (cmd, opts, ctx) =>
          @cmdStart cmd, opts, ctx
      }
      {
        name: "powerOn"
        help: "send powerOn request the TV"
        isAvailable: (ctx) ->
          @emulator != null & @connector != null && @connector.connected
        handler: (cmd, opts, ctx) =>
          @cmdSendPowerOn cmd, opts, ctx
      }
    ]

    for cmd in cmds
      @shell.registerCommand cmd

  start: ->
    @initShell()
    @initCommands()
    @shell.startConsole()

  # Commands Stuff
  cmdCreateAvailable: (ctx) ->
    @emulator is null

  cmdCreateHandler: (cmd, opts, ctx) ->
    @emulator = switch opts.class
      when "samsung" then new SamsungEmulator()
      when "lg" then new LgEmulator()

    if @emulator
      @logger.log "Emulator for #{opts.class} created!" if @logger
    else
      @logger.error "Could not create emulator!".red if @logger

  cmdCreateConnectorAvaiable: (ctx) ->
    @connector is null

  cmdCreateConnector: (cmd, opts, ctx) ->
    @logger.log "Create connector -> TODO" if @logger
    @connector = switch opts.class
      when "tcp" then new TcpConnector opts

    if @connector
      @logger.log "Connector for #{opts.class} created!" if @logger
      @connector.setLogger @logger if @logger
    else
      @logger.error "Could not create connector!".red if @logger


  cmdStart: (cmd, opts, ctx) ->
    @logger.log "Starting...", @connector if @logger

    @bindConnectorEmulator()

    @logger.log "setLogger on connector"
    @connector.setLogger @logger

    @connector.start()

  cmdSendPowerOn: (cmd, opts, ctx) ->
    @logger.log "Send PowerOn" if @logger

  _bindCommandClient: (data) ->
    @logger.log "Binding data", data

  # binding stuff
  bindConnectorEmulator: ->
    @connector.on "data", (data) =>
      @_bindCommandClient data

module.exports = ClientCli
