
BaseEmulator = require './base'


###
# Each tv has a specific id
#
# Protocol
#
# rx [cmd1][cmd2] [id] [data][Cr]
# tx [cmd2] [id] [OK][data][x]
#
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

  init: ->
    @id = 1



  process: (data, callback) ->
    callback = callback || (->)

    cbValid = (err) =>
      return callback err if err
      args = data.split ' '

      cmd = args[0]
      fctName = "_cmd_#{cmd}"
      return @[fctName](args, callback)

    @isValid data, cbValid


  isValid: (data, callback) ->
    validCmd1 = ['j', 'k', 'm', 'x']

    cmd1 = null
    for c in validCmd1
      cmd1 = c if c == data[0]

    if cmd == null
      callback "Unknown command #{cmd}, the first char must start by #{validCmd1}"
      return false

    args = data.split ' '

    if args.length != 3
      callback "Invalid lenght of the command, must have 2 space but #{args.length} given"
      return false

    cmd = args[0]
    fct = "_cmd_#{cmd}"
    if typeof @[fct] != 'function'
      "The command #{cmd} is not supported!"
      return false
    return true

  _cmd_ka: (data, callback) ->

  _cmd_kb: (data, callback) ->

  _cmd_kc: (data, callback) ->

  _cmd_kd: (data, callback) ->

  _cmd_ke: (data, callback) ->

  _cmd_kf: (data, callback) ->

  _cmd_kg: (data, callback) ->

  _cmd_kh: (data, callback) ->

  _cmd_ki: (data, callback) ->

  _cmd_kj: (data, callback) ->

  _cmd_kk: (data, callback) ->

  _cmd_kl: (data, callback) ->

  _cmd_km: (data, callback) ->

  _cmd_kr: (data, callback) ->

  _cmd_ks: (data, callback) ->

  _cmd_kt: (data, callback) ->

  _cmd_ku: (data, callback) ->

  _cmd_jp: (data, callback) ->

  _cmd_jq: (data, callback) ->

  _cmd_ma: (data, callback) ->

  _cmd_mb: (data, callback) ->

  _cmd_mc: (data, callback) ->

  _cmd_xb: (data, callback) ->
