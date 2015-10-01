
BaseEmulator = require './base'

###
# Each tv has a specific id
#
# Protocol
# rx [cmd1][cmd2] [id] [data][Cr]
# tx [cmd2] [id] [OK][data][x]
###
class LgEmulator extends BaseEmulator

  COMMANDS = {
    ka: { name: "Power Control" }
    kb: { name: "Input Select (main picture input)" }
    kc: { name: "Aspect Ratio" }
    kd: { name: "Screen Mute" }
    ke: { name: "Volume Mute" }
    kf: { name: "Volume Control" }
    kg: { name: "Contrast" }
    kh: { name: "Brightness" }
    ki: { name: "Color" }
    kj: { name: "Tint" }
    kk: { name: "Sharpness" }
    kl: { name: "OSD Select" }
    km: { name: "Remote Control Lock Mode" }
    kr: { name: "Treble" }
    ks: { name: "Bass" }
    kt: { name: "Balance" }
    ku: { name: "Color Temperature" }
    jp: { name: "ISM Method" }
    jq: { name: "Low Power" }
    ma: { name: "Channel Tunning" }
    mb: { name: "Channel Add/Del" }
    mc: { name: "Key IR" }
    xb: { name: "Input Select (main picture input)" }
  }

  class Command
    constructor: (data) ->
      if data instanceof Buffer
        data = data.toString('ascii')

      @data = data.slice(0, -1)
      @args = @data.split ' '
      @cmd = @args[0]
      @id_str = @args[1]
      @id = parseInt(@args[1], 10)
      @params = @args[2]
      @name = COMMANDS[@cmd].name

  init: ->
    @id = 1
    # default source on LG
    @sourcesMappingLegacy = [
      [0, 1],  # 0
      [2, 3], # 1
      4, # 2
      5, # 3
      6, # 4
      7, # 5
      -1, # 6
      8, # 7
      9, # 8
      10  # 9
    ]
    ###
    # tvMode
    # 0 = Antenna
    # 1 = Cable
    ###
    @tvMode = 0
    @sources = [
      @SOURCE_TYPE.TV
      @SOURCE_TYPE.TV
      @SOURCE_TYPE.TV
      @SOURCE_TYPE.TV
      @SOURCE_TYPE.AV
      @SOURCE_TYPE.AV
      @SOURCE_TYPE.COMPONENT
      @SOURCE_TYPE.COMPONENT
      @SOURCE_TYPE.PC
      @SOURCE_TYPE.HDMI
      @SOURCE_TYPE.HDMI
      @SOURCE_TYPE.HDMI
      @SOURCE_TYPE.HDMI
    ]

    @sourcesMapping = [
      { type: @SOURCE_TYPE.TV, id: 0, idx: 0 } # DTV Antenna
      { type: @SOURCE_TYPE.TV, id: 1, idx: 1 } # DTV Cable
      { type: @SOURCE_TYPE.TV, id: 10, idx: 2 } # Analog Antenna
      { type: @SOURCE_TYPE.TV, id: 11, idx: 3 } # Analog Cable
      { type: @SOURCE_TYPE.AV, id: 20, idx: 4 } # AV1
      { type: @SOURCE_TYPE.AV, id: 21, idx: 5 } # AV2
      { type: @SOURCE_TYPE.COMPONENT, id: 40, idx: 6 } # Component 1
      { type: @SOURCE_TYPE.COMPONENT, id: 41, idx: 7 } # Component 2
      { type: @SOURCE_TYPE.PC, id: 60, idx: 8 } # RGB PC
      { type: @SOURCE_TYPE.HDMI, id: 90, idx: 9 } #ie HDMI1
      { type: @SOURCE_TYPE.HDMI, id: 91, idx: 10 } #ie HDMI2
      { type: @SOURCE_TYPE.HDMI, id: 92, idx: 11 } #ie HDMI3
      { type: @SOURCE_TYPE.HDMI, id: 93, idx: 12 } #ie HDMI4
    ]

  process: (data, callback) ->
    callback = callback || (->)

    if data instanceof Buffer
      data = data.toString('ascii')

    cbValid = (err) =>
      return callback err if err

      cmd = new Command(data)
      fctName = "_cmd_#{cmd.cmd}"

      return @[fctName](cmd, callback)

    @isValid data, cbValid

  isValid: (data, callback) ->
    if data instanceof Buffer
      data = data.toString('ascii')

    validCmd1 = ['j', 'k', 'm', 'x']

    cmd1 = null
    for c in validCmd1
      cmd1 = c if c == data[0]

    if cmd == null
      @logger.log "Unknown command #{cmd}, the first char must start by #{validCmd1}" if @logger
      callback "Unknown command #{cmd}, the first char must start by #{validCmd1}"
      return false

    args = data.split ' '

    if args.length != 3
      @logger.log "Invalid lenght of the command, must have 2 space but #{args.length} given" if @logger
      callback "Invalid lenght of the command, must have 2 space but #{args.length} given"
      return false

    cmd = args[0]
    fct = "_cmd_#{cmd}"
    if typeof @[fct] != 'function'
      @logger.log "The command #{cmd} is not supported!" if @logger
      callback "The command #{cmd} is not supported!"
      return false

    if data.slice(-1) != "\r"
      @logger.log "The command must end with <CR>" if @logger
      callback "The command must end with <CR>"
      return false;

    callback null
    return true

  _createSuccessResponse: (cmd, data) ->
    @_createResponse cmd, true, data

  _createFailedResponse: (cmd, data) ->
    @_createResponse cmd, false, data

  _createFailedResponseIllegalCode: (cmd) ->
    @_createFailedResponse cmd, 1

  _createFailedResponseNotSupported: (cmd) ->
    @_createFailedResponse cmd, 2

  _createFailedResponseWaitMoreTime: (cmd) ->
    @_createFailedResponse cmd, 3

  _createResponse: (cmd, isValid, data) ->
    ret = "OK"
    ret = "NG" unless isValid

    data = "#{data}"
    if data.length == 1
      data = "0#{data}"

    response = "#{cmd.cmd.slice(-1)} #{cmd.id_str} #{ret}#{data}x\r"
    @logger.log "> RET > #{response}" if @logger
    response

  _cmd_ka: (cmd, callback) ->
    # get mode
    if cmd.params == 'FF'
      state = 0
      state = 1 if @isPowerOn()
      response = @_createSuccessResponse cmd, state
    else # set mode
      state = parseInt(cmd.params, 10)
      if state != 0 && state != 1
        response = @_createFailedResponse cmd, 1
      else
        if state == 0 && @isPowerOn()
          @setPowerOff()
        else if state == 1 && @isPowerOff()
          @setPowerOn()
        response = @_createSuccessResponse cmd, state

    callback null, @, response
    response

  _cmd_kb: (cmd, callback) ->
    if cmd.params == 'FF'

      idx = @sourcesMappingLegacy.indexOf @currentSourceIndex

      response = @_createSuccessResponse cmd, idx
    else
      sourceIdxLegacy = parseInt cmd.params, 10

      if 0 <= sourceIdxLegacy < @sourcesMappingLegacy.length

        if @sourcesMappingLegacy[sourceIdxLegacy] == -1 # not available
          response = @_createFailedResponseIllegalCode cmd
        else
          sourceIdx = @sourcesMappingLegacy[sourceIdxLegacy]
          sourceIdx = sourceIdx[@tvMode] if sourceIdx instanceof Array
          @setSource sourceIdx
          response = @_createSuccessResponse cmd, @sourcesMappingLegacy.indexOf(@currentSourceIndex)
      else
        response = @_createFailedResponseIllegalCode cmd

    callback null, @, response
    response

  _cmd_kc: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  # screen mute
  _cmd_kd: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  # volume mute
  _cmd_ke: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  # volume control
  _cmd_kf: (cmd, callback) ->
    if cmd.params == 'FF'
      response = @_createSuccessResponse cmd, @getVolume().toString(16).toUpperCase()
    else
      volumeLevel_ = parseInt cmd.params, 16
      @setVolume volumeLevel_

      if @getVolume() == volumeLevel_
        response = @_createSuccessResponse cmd, cmd.params
      else
        response = @_createFailedResponseIllegalCode cmd

    callback null, @, response
    response

  _cmd_kg: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kh: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_ki: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kj: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kk: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kl: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_km: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kr: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_ks: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_kt: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_ku: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_jp: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_jq: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_ma: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_mb: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  _cmd_mc: (cmd, callback) ->
    response = @_createFailedResponseNotSupported cmd
    callback null, @, response
    response

  # Input select
  _cmd_xb: (cmd, callback) ->
    if cmd.params == 'FF'
      source  = @getActiveSource();
      response = @_createSuccessResponse cmd, source.id
    else
      sourceId = parseInt cmd.params, 10

      sources_ = []
      sources_.push s for s in @sourcesMapping when s.id == sourceId

      @logger.log "-> res sources_ => #{sources_}" if @logger

      if sources_.length == 0
        response = @_createFailedResponseNotSupported cmd
      else
        source = sources_[0]
        @setSource source.idx
        response = @_createSuccessResponse cmd, source.id

    callback null, @, response
    response

module.exports = LgEmulator
