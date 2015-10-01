
require 'colors'

shell = require 'simple-shell'

SamsungEmulator = require '../emulator/samsungv2'
LgEmulator = require '../emulator/lg'

TcpConnector = require '../connector/tcp'
UnixConnector = require '../connector/unix'

class ServerCli

  constructor: ->
    @emulator = null
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
      name: "node-tv-server"
      exitMessage: "End of the server"
      prompt: "node TV server"
      exit: =>
        @exit()
    }
    @shell.initialize shellOps

  initCommands: ->
    cmds = [
      {
        name: "create"
        help: "Create a TV server"
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
            help: "Select the connector to use. Values possible: tcp, unix, serial"
            required: true
            allowedValues: [ 'tcp', 'unix', 'serial' ]
          }
          path: {
            help: "UNIX: The path"
          }
          ip: {
            help: "TCP: The ip parameter"
          }
          port: {
            help: "TCP: The port parameter"
          }
        }
        handler: (cmd, opts, ctx) =>
          @cmdCreateConnector cmd, opts, ctx
      }
      {
        name: "start"
        help: "Start the emulator"
        isAvailable: (ctx) =>
          @emulator != null && @connector != null
        handler: (cmd, opts, ctx) =>
          @cmdStart cmd, opts, ctx
      }
      {
        name: "status"
        help: "Get the status of the emulator"
        isAvailable: =>
          @emulator != null && @connector != null && @connector.connected
        handler: (cmd, opts, ctx) =>
          @cmdStatus cmd, opts, ctx
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
      when "unix" then new UnixConnector opts

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

  cmdStatus: (cmd, opts, ctx) ->
    @logger.log "Getting current status of the TV" if @logger
    @logger.log @emulator

  _bindCommandEmulator: (data) ->
    @emulator.process data, (error, emulator, response) =>
      return @logger.error "Error: #{error}" if error
      @logger.log "End process cmd ->", "error=", error, "response=", response
      @connector.write response

  # binding stuff
  bindConnectorEmulator: ->
    @connector.on "data", (data) =>
      @_bindCommandEmulator data

  exit: ->
    @connector.close()

module.exports = ServerCli
