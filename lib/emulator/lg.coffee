
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

  _createResponse: (cmd, isValid, data) ->
    ret = "OK"
    ret = "NG" unless isValid

    response = "#{cmd.cmd.slice(-1)} #{cmd.id_str} #{ret}#{data}x\r"
    @logger.log "> RET > #{response}" if @logger
    response

  _cmd_ka: (cmd, callback) ->
    # get mode
    if cmd.params == 'FF' || cmd.params == 'ff'
      state = 0
      state = 1 if @isPowerOn()
      response = @_createResponse cmd, true, state
    else # set mode
      state = parseInt(cmd.params, 10)
      if state != 0 && state != 1
        response = @_createResponse cmd, false, 1
      else
        if state == 0 && @isPowerOn()
          @setPowerOn()
        else if state == 1 && @isPowerOn() == false
          @setPowerOff()
        response = @_createResponse cmd, true

    callback null, @, response
    response

  _cmd_kb: (cmd, callback) ->

  _cmd_kc: (cmd, callback) ->

  _cmd_kd: (cmd, callback) ->

  _cmd_ke: (cmd, callback) ->

  _cmd_kf: (cmd, callback) ->

  _cmd_kg: (cmd, callback) ->

  _cmd_kh: (cmd, callback) ->

  _cmd_ki: (cmd, callback) ->

  _cmd_kj: (cmd, callback) ->

  _cmd_kk: (cmd, callback) ->

  _cmd_kl: (cmd, callback) ->

  _cmd_km: (cmd, callback) ->

  _cmd_kr: (cmd, callback) ->

  _cmd_ks: (cmd, callback) ->

  _cmd_kt: (cmd, callback) ->

  _cmd_ku: (cmd, callback) ->

  _cmd_jp: (cmd, callback) ->

  _cmd_jq: (cmd, callback) ->

  _cmd_ma: (cmd, callback) ->

  _cmd_mb: (cmd, callback) ->

  _cmd_mc: (cmd, callback) ->

  _cmd_xb: (cmd, callback) ->

module.exports = LgEmulator
