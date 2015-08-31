
BaseEmulator = require './base'

###
# SamsungV2Emulator class
#
# Ack response:
# | 0x58 | 0x00 | 0x00 | 0x01 | 0x__ | 0x__ |
# | CB   | CMD1 | CMD2 | DLEN | DAT1 | chks |
###
class SamsungV2Emulator extends BaseEmulator

  LENGTH_MIN = 4
  OFFSET_CMD = 2
  OFFSET_LENGTH = 3
  OFFSET_DATA = 4

  CMD_FROM_CLIENT_TO_SERVER = 0
  CMD_FROM_SERVER_TO_CLIENT = 1

  COMMANDS = {
    0x00: {
      name: "Request TV Status"
      length: 0 # data length
    }
    0x01: {
      name: "Power"
      length: 1
    }
    0x02: {
      name: "Set parameter"
      length: 2
    }
    0x03: {
      name: "OSD Control"
      length: 3
    }
    0x04: {
      name: "Display OSD Text"
      length: {
        min: 3
        max: 32
      }
    }
    0x05: {
      name: "IR code to TV"
      length: 2
    }
    0x06: {
      name: "Select Input Source"
      length: {
        min: 1
        max: 22
      }
    }
    0x07: {
      name: "Select Teletext/MHEG"
    }
    0x08: {
      name: "Picture Size"
    }
    0x09: {
      name: "Add Program to TV"
    }
    0x0a: {
      name: "Tune Channel (Analog)"
    }
    0x0b: {
      name: "Tune Channel (Digital)"
    }
    0x0c: {
      name: "Activate/Desactivate EPG"
    }
    0x0d: {
      name: "Set Volume"
    }
    0x0e: {
      name: "Set World Time Clock"
    }
    0x0f: {
      name: "Set World Time Clock Display Mode"
    }
    0x10: {
      name: "Navigate World Time Clock"
    }
    0x11: {
      name: "Set RJP Source Priority"
    }
    0x12: {
      name: "Set PMO LED Clock"
    }
    0x13: {
      name: "Set PMO LED Display Mode"
    }
    0x14: {
      name: "Set Baud Rate"
    }
    0x15: {
      name: "Activate/Desactivate Session"
    }
    0x16: {
      name: "Enable/Disable OSD Display"
    }
    0x17: {
      name: "Select Subtitle Status"
    }
    0x18: {
      name: "Request Subtitle Language"
    }
    0x19: {
      name: "Select Audio Language"
    }
    0x1a: {
      name: "Request Audio Status"
    }
    0x1b: {
      name: "Request TV-Identify"
    }
    0x1c: {
      name: "Request TV Firmware Version"
    }
    0x1d: {
      name: "Picture Mode"
    }
    0x1e: {
      name: "Set Analog Level"
    }
    0x1f: {
      name: "LED Message"
    }
    0x20: {
      name: "SBB Status"
    }
    0x21: {
      name: "Tune to Program"
    }
    0x22: {
      name: "PMO LED Message Display"
    }
    0x23: {
      name: "Delete Channel Map"
    }
    0x24: {
      name: "Update Channel Map"
    }
    0x25: {
      name: "Set Power On Status"
    }
    0x26: {
      name: "Request DVB Status"
    }
    0x27: {
      name: "Request Main MCU Firmware Version"
    }
    0x28: {
      name: "Request Sub MCU Firmware Version"
    }
    0x29: {
      name: "Sound Mode"
    }
    0x30: {
      name: "Request Picture Size Status"
    }
    0x31: {
      name: "Enable/Disable Digital Text"
    }
    0x32: {
      name: "Select Antenna Input"
    }
    0x33: {
      name: "Enable/Disable USB Device"
    }
    0x34: {
      name: "Display Custom Channel Banner"
    }
    0x35: {
      name: "PIP Control"
    }
  }

  ###
  # SamsungCommand
  #
  # This class is a internal class in order to handle a specific command
  ###
  class Command
    constructor: (data) ->
      @data = data
      @prefix = @data[0]
      @cmd1 = @data[1]
      @cmd2 = @data[2]
      @dlen = @data[3]
      @args = new Uint8Array @data
      @args = @args.subarray(4, @args.length - 1)
      @name = COMMANDS[@cmd2].name

  init: ->
    @debug = false

  getFunctionName: (cmd) ->
    code = cmd.toString(16)
    code = "0#{code}" if code.length == 1
    return "_cmd0x#{code}"

  process: (data, callback) ->

    callback = callback || (->)

    cbValid = (err) =>
      return callback err if err

      cmd = new Command data

      fctName = @getFunctionName cmd.cmd2
      @logger.log "SamsungV2::Receive command #{cmd.name}" if @logger
      return @[fctName](cmd, callback)

      callback null

    return false unless @isValid(data, cbValid)
    return true

  ###
  # isValid
  #
  # This function return true if the command is a valid command
  #
  # @param {Buffer} cmd the command to check
  # @param {Function} callback called if defined (optionnal)
  #
  # @return {Boolean} True if valid, otherwise false
  ###
  isValid: (cmd, callback) ->

    cmd = new Buffer(cmd, 'hex') if typeof cmd is "string"
    cmd = new Buffer cmd unless typeof cmd is Buffer

    callback = callback || (->)

    # first byte must be 0x58
    if cmd[0] != 0x58
      callback "The first byte is not correct, expected 0x58 but 0x#{cmd[0].toString(16)} given"
      return false

    # the length must be at least 5
    if cmd.length < LENGTH_MIN
      callback "The command length must have at least 5 bytes"
      return false

    length = cmd[OFFSET_LENGTH]
    if cmd.length < length + OFFSET_DATA
      callback "The data length is not correct"
      return false

    sum = 0
    for byte, idx in cmd
      if idx != length + OFFSET_DATA
        sum += byte

    sum = sum & 0xff

    if cmd[OFFSET_DATA + length] != sum
      @logger.log "The checksum is not good" if @logger
      callback "The checksum is not good"
      return false

    if COMMANDS.hasOwnProperty(cmd[OFFSET_CMD]) is false
      @logger.log "The command #{cmd[OFFSET_CMD]} is not defined" if @logger
      callback "The command #{cmd[OFFSET_CMD]} is not defined"
      return false

    cmdSpec = COMMANDS[cmd[OFFSET_CMD]]

    if cmdSpec.length
      if typeof cmdSpec.length is 'number'
        callback "Wrong number of arguments" if length isnt cmdSpec.length
      else
        callback "Wrong number of arguments" unless cmdSpec.length.min <= length <= cmdSpec.length.max

    callback null
    return true

  _createCommand: (cmd1, cmd2, datas, prefix) ->
    prefix = prefix || 0x58
    nbData = datas.length
    args = [prefix, cmd1, cmd2, nbData, datas]
    args = [].concat.apply([], args)

    # create checksum
    chksum = args.reduce (total, value) -> total + value
    chksum = chksum & 0xff

    args.push chksum

    new Uint8Array args

  response: (cmd)->
    data = new Buffer(6)
    # data.writeUIntBE 0x58 0x00 00 01 01, 0, 5

  setDebug: ->
    @debug = true

  unsetDebug: ->
    @debug = false

  ###
  # setStatus
  #
  # Simulate TV power on and power off
  #
  # The TV could take between 5 to 10 s to answer
  # We will define 7s as value
  #
  # @param {STATUS}
  ###
  setStatus: (status) ->
    if @debug
      super status
    else
      unless @status == status
        setTimeout (=>
          @status = status
          @emit 'statusChanged', @, status
        ), 7 * 1000
    @

  dumpUa: (ua) ->
    h = ''
    for i in ua
      h += "\\0x" + i.toString(16)
    h

  ###
  # Method called for specific message
  ###

  ###
  # CMD: 0x00
  #
  # Request
  # 1. Request TV Status 0x80 0x00 SBB request for TV status
  #
  # Response
  # 2. TV status 0x00 0x01 TV status info to SBB/STB
  ###
  _cmd0x00: (command, callback) ->
    callback = (->) unless typeof callback == 'function'
    callback = callback || (->)

    data = [0x00, 0x00, 0x00, 0x00]
    data[0] = data[0] | (1 << 4) if @isPowerOn()

    response = @_createCommand 0x00, 0x01, data, 0x00

    dump_response = @dumpUa(response)
    @logger.log "SamsungV2::_cmd0x00 |||| => response #{dump_response}" if @logger


    callback null, @, response
    response

  _cmd0x01: (command, callback) ->
    callback = (->) unless typeof callback == 'function'
    callback = callback || (->)

    statusAsked = command.args[0] & (1 << 7)

    if statusAsked
      @setPowerOn()
    else
      @setPowerOff()

    response = @_createCommand 0x00, 0x00, [0x01]

    callback null, @, response
    response

  ###
  # Set parameter
  ###
  _cmd0x02: (command, callback) ->
    callback = (->) unless typeof callback == 'function'
    callback = callback || (->)



    response = @_createCommand 0x00, 0x00, [0x01]

    callback null, @, response
    response


module.exports = SamsungV2Emulator
