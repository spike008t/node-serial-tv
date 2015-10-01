
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
    @serial = new SerialPort @path, @options

  start: ->

  close: ->

  write: (data) ->
    super data


modules.export = SerialConnector
