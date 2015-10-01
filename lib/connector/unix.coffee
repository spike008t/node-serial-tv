
'use strict'

net = require 'net'
fs = require 'fs'

TcpConnector = require './tcp'

class UnixConnector extends TcpConnector

  constructor: (params) ->
    super params
    @path = @params.path || "/tmp/socket_unix"
    @server = null
    @client = null # used on server mode

  connect: ->
    super()
    @server = net.connect {path: @path}, =>
      @logger.log "Connected to #{@path}"
      @connected = true
      @emit "connected", @

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

    @server.listen @path, =>
      @onListenHandler()

  close: ->
    super()
    fs.unlinkSync @

module.exports = UnixConnector
