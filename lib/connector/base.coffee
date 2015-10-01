
EventEmitter = require('events').EventEmitter

class BaseConnector extends EventEmitter

  MODE_UNKNOWN = "unknown"
  MODE_SERVER = "server"
  MODE_CLIENT = "client"

  constructor: (params) ->
    @connected = false
    @logger = params.logger || null
    @mode = MODE_UNKNOWN
    @params = params

  isModeServer: ->
    @mode == MODE_SERVER

  isModeClient: ->
    @mode == MODE_CLIENT

  setLogger: (logger) ->
    @logger = logger

  connect: ->
    if @connected
      @logger.log "Connector already connected!" if @logger
      return null
    @logger.log "Starting connection" if @logger

  start: ->
    if @connected
      @logger.log "Connector already connected!" if @logger
      return null
    @logger.log "Starting server" if @logger

  close: ->
    if @connected is false
      @logger.log "Connector not started!"
      return null

    @logger.log "Closing connector" if @logger

  write: (data) ->

  isConnected: ->
    @connected

module.exports = BaseConnector
