
'use strict'

net = require 'net'

BaseConnector = require './base'

class TcpConnector extends BaseConnector
  constructor: (params) ->
    super params
    @ip = @params.ip || "0.0.0.0"
    @port = @params.port || 54001
    @server = null
    @client = null

  connect: ->
    super()
    client = net.connect {ip: @ip, port: @port}
    @onConnectionHandler client

  start: ->
    super()
    @server = net.createServer (c) =>
      @onConnectionHandler c

    @server.on 'error', (e) =>
      @onError e

    @server.on 'end', =>
      @emit "end", @

    @server.on 'listen', =>
      @onListenHandler()

    @server.listen @port, =>
      @onListenHandler()

  close: ->
    super
    @server.close()

  write: (data) ->
    super data

    if @client is null
      @logger.error "Could not send data, no client connected!".red if @logger
      return

    @logger.log "SEND:", data if @logger
    @client.write data
    @emit "send", data, @

  # event handler
  onError: (e) ->
    if e.code == 'EADDRINUSE'
      @logger.error "Address in use... retrying...".red if @logger
      setTimeout =>
        @server.close()
        @server.listen
    @emit "error", e, @

  onConnectionHandler: (client) ->
    @logger.log "New connection received!" if @logger
    if @client isnt null
      @logger.log "Closing duplicated client!" if @logger
      @client.close()
      @client = null
      return false
    @logger.log "Accepting new client!" if @logger
    @client = client

    @client.on 'data', (data) =>
      @logger.log "RECV:", data if @logger
      @emit "data", data, @

    @client.on 'end', =>
      @logger.log "Client disconnected" if @logger
      @client = null
      @emit "end", client, @


  onListenHandler: ->
    @logger.log "TCP: Listening...".green if @logger
    @connected = true
    @emit "connected", @

module.exports = TcpConnector
