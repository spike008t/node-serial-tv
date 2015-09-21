
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

  initSourceList: ->

    # adding a new source type -> WiseLink
    @SOURCE_TYPE.WISELINK = 10

    ###
    # Sources values
    # bit 3-0
    # 0000 [0] = RF
    # 0001 [1] = SCART1
    # 0010 [2] = SCART2
    # 0011 [3] = AV1
    # 0100 [4] = AV2
    # 0101 [5] = S-VIDEO1
    # 0110 [6] = S-VIDEO2
    # 0111 [7] = COMPONENT1
    # 1000 [8] = COMPONENT2
    # 1001 [9] = PC1
    # 1010 [10]= PC2
    # 1011 [11]= HDMI1
    # 1100 [12]= HDMI2
    # 1101 [13]= HDMI3
    # 1110 [14]= HDMI4
    # 1111 [15]= WiseLink
    ###
    @SOURCES_LIST = [
      {
        name: "RF"
        type: @SOURCE_TYPE.RF
        offset: 0
      }
      {
        name: "SCART1"
        type: @SOURCE_TYPE.SCART
        offset: 0
      }
      {
        name: "SCART2"
        type: @SOURCE_TYPE.SCART
        offset: 1
      }
      {
        name: "AV1"
        type: @SOURCE_TYPE.AV
        offset: 0
      }
      {
        name: "AV2"
        type: @SOURCE_TYPE.AV
        offset: 1
      }
      {
        name: "S-VIDEO1"
        type: @SOURCE_TYPE.SVIDEO
        offset: 0
      }
      {
        name: "S-VIDEO2"
        type: @SOURCE_TYPE.SVIDEO
        offset: 1
      }
      {
        name: "COMPONENT1"
        type: @SOURCE_TYPE.COMPONENT
        offset: 0
      }
      {
        name: "COMPONENT2"
        type: @SOURCE_TYPE.COMPONENT
        offset: 1
      }
      {
        name: "PC1"
        type: @SOURCE_TYPE.PC
        offset: 0
      }
      {
        name: "PC2"
        type: @SOURCE_TYPE.PC
        offset: 1
      }
      {
        name: "HDMI1"
        type: @SOURCE_TYPE.HDMI
        offset: 0
      }
      {
        name: "HDMI2"
        type: @SOURCE_TYPE.HDMI
        offset: 1
      }
      {
        name: "HDMI3"
        type: @SOURCE_TYPE.HDMI
        offset: 2
      }
      {
        name: "HDMI4"
        type: @SOURCE_TYPE.HDMI
        offset: 3
      }
      {
        name: "WiseLink"
        type: @SOURCE_TYPE.HDMI
        offset: 0
      }
    ]

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

    @isValid(data, cbValid)

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

  ###
  # Set source from bytes
  #
  # bit 3-0
  # 0000 = RF
  # 0001 = SCART1
  # 0010 = SCART2
  # 0011 = AV1
  # 0100 = AV2
  # 0101 = S-VIDEO1
  # 0110 = S-VIDEO2
  # 0111 = COMPONENT1
  # 1000 = COMPONENT2
  # 1001 = PC1
  # 1010 = PC2
  # 1011 = HDMI1
  # 1100 = HDMI2
  # 1101 = HDMI3
  # 1110 = HDMI4
  # 1111 = WiseLink
  ###
  _setSource: (byte) ->
    return false unless 0 < idx < 15
    idx = byte & 15
    sourceDefinitionWanted = @SOURCES_LIST[idx]
    offsetWanted = sourceDefinitionWanted.offset || 0
    offset = 0
    sourcePos = 0
    for sourceType in @sources
      if sourceType == sourceDefinitionWanted.type
        if offset == offsetWanted
          @setSource sourcePos
          return true
        else
          offset++
      else
        sourcePos++

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

  ###
  # Set input source
  ###
  _cmd0x06: (command, callback) ->
    callback = (->) unless typeof callback == 'function'
    callback = callback || (->)

    data1 = command.args[0]

    osdType = 0
    osdType = 1 if data1 & (1 << 7)

    # treat response
    response = @_createCommand 0x00, 0x00, [0x01]

    callback null, @, response
    response

module.exports = SamsungV2Emulator
