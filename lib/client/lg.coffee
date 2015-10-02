'use strict'

BaseDevice = require './base'

LgEmulator = require '../emulator/lg'

class LgClient extends BaseDevice
  constructor: (params)->
    params = params || {}
    super params
    @id = params.id || "00"
    @cmds = {
      current: {
        data: null
        cb: null
      }
      toSend: []
      sended: []
    }

  # method to check if a response is valid
  isValid: (data, callback) ->
    if data instanceof Buffer
      data = data.toString('ascii')

    unless /^[a-z] [0-9]{2} (OK|NG)[0-9]{2}x$/.match data
      @logger.log "The received data is not a valid response" if @logger

    @logger.log "The received data is valid!" if @logger

  powerStatus: ->
    cmd = "ka 00 FF\r"
    @send cmd

  powerOn: ->
    cmd = "ka 00 01\r"
    @send cmd

  powerOff: ->
    cmd = "ka 00 00\r"
    @send cmd

  setSource: (type, idx) ->
    true

  recv: (data) ->
    @logger.log "Received: #{data} -> ", data.toString() if @logger

module.exports = LgClient
