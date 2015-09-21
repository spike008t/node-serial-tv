
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

  initSourceList: ->
    @SOURCES_LIST = [
      {
        name: "DTV",
        type: @SOURCE_TYPE.DTV
        offset: 0
        data: {
          kb: 0
          xb: 0
        }
      }
      {
        name: "DTV"
        type: @SOURCE_TYPE.RF
        offset: 0
        data: {
          kb: 1
          xb: 1
        }
      }
      {
        name: "AV1"
        type: @SOURCE_TYPE.AV
        offset: 0
        data: {
          kb: 2
          xb: 20
        }
      }
      {
        name: "AV2"
        type: @SOURCE_TYPE.AV
        offset: 1
        data: {
          kb: 3
          xb: 21
        }
      }
      {
        name: "COMPONENT1"
        type: @SOURCE_TYPE.COMPONENT
        offset: 0
        data: {
          kb: 4
          xb: 40
        }
      }
      {
        name: "COMPONENT2"
        type: @SOURCE_TYPE.COMPONENT
        offset: 1
        data: {
          kb: 5
          xb: 41
        }
      }
      {
        name: "RGB-PC"
        type: @SOURCE_TYPE.PC
        offset: 0
        data: {
          kb: 6
          xb: 60
        }
      }
      {
        name: "HDMI1/DVI"
        type: @SOURCE_TYPE.HDMI
        offset: 0
        data: {
          kb: 7
          xb: 90
        }
      }
      {
        name: "HDMI2"
        type: @SOURCE_TYPE.HDMI
        offset: 1
        data: {
          kb: 8
          xb: 91
        }
      }
    ]

  process: (data, callback) ->
    callback = callback || (->)


  isValid: (data, callback) ->
    validCmd1 = ['j', 'k', 'm', 'x']

    cmd1 = null
    for c in validCmd1
      cmd1 = c if c == data[0]

    callback "Unknown command #{cmd}, the first char must start by #{validCmd1}" unless cmd1

    cmd = data.substr(0, 2)


    _cmd_ka: (data, callback) ->
    _cmd_kb: (data, callback) ->
    _cmd_kc: (data, callback) ->
    _cmd_kd: (data, callback) ->
    _cmd_ke: (data, callback) ->
    _cmd_kf: (data, callback) ->
    _cmd_kg: (data, callback) ->
    _cmd_kh: (data, callback) ->
