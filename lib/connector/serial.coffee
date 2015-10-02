
'use strict'

BaseConnector = require './base'

class SerialConnector extends BaseConnector
  constructor: (params) ->
    super params
    @path = @params.path || '/dev/cu.usbserial'
    @timeout = @params.timeout || 10
    @timeout = @timeout * 1000
    @serial = null
    @options = {
      baudrate: 9600
      parser: serialPort.parsers.raw
    }
    @options.baudrate = @params.baudrate || @options.baudrate

  connect: ->
    super()
    @serial = new SerialPort @path, @options

  start: ->
    super()

  close: ->
    super()

  write: (data) ->
    super data
    if @serial is null
      @logger.error "Could not send data, not connected!".red if @logger
      return

    @logger.log "SEND:", data if @logger
    @serial.write


modules.export = SerialConnector
