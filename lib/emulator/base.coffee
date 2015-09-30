
EventEmitter = require('events').EventEmitter

###
# BaseEmulator
#
# The base class for the emulator
#
# This class emit the following events
# @event volumeChanged
# @event statusChanged
###
class BaseEmulator extends EventEmitter

  ###
  # The subclass should not override the constructor
  #
  # In order to init, please override init
  # @see init()
  ###
  constructor: (options)->
    options = options || {}
    @_init options
    @setOptions options
    @setLogger options.logger if options.logger
    @debug = false

  ###
  # This method will init everything.
  #
  # In order to change the behavior, please override method setOptions
  # @see setOptions()
  ###
  _init: (options)->
    # const
    @STATUS = {
      UNKNOWN: -1
      OFF: 0
      ON: 1
      STANDBY: 2
    }

    @SOURCE_TYPE = {
      NONE: 0
      TV: 1
      HDMI: 2
      COMPOSITE: 3
      AV: 4
      COMPONENT: 5
      SVIDEO: 6
      SCART: 7
      PC: 8
      RF: 9
      DTV: 10
    }

    @logger = null

    ## init defaults
    @status = options.status || @STATUS.OFF
    @screenStatus = options.screenStatus || @STATUS.ON
    @volumeStatus = options.volumeStatus || @STAUTS.ON
    @volume = options.volume || 10
    @volumeMax = options.volumeMax || 99
    @volumeMin = options.volumeMin || 0
    @sources = [
      @SOURCE_TYPE.NONE
      ,@SOURCE_TYPE.TV
      ,@SOURCE_TYPE.HDMI #emulate HDMI1
      ,@SOURCE_TYPE.HDMI #emulate HDMI2
    ]
    @currentSourceIndex = 0

    @init()

  # override this method to force specific value as init
  init: ->

  setOptions: (options) ->

  enableSource: (sourceIndex) ->
    @setSource sourceIndex

  setSource: (sourceIndex, emit) ->
    emit = true if emit is undefined
    if 0 <= sourceIndex < @sources.length
      @currentSourceIndex = sourceIndex
      @logger.log "Emit 'sourceChanged'" if @logger
      @emit 'sourceChanged', @, @currentSourceIndex, @sources[@currentSourceIndex] if emit
    else
      @logger.log "Could not set the sourceIndex #{sourceIndex}, the index must be between 0 and #{@sources.length}" if @logger
    @

  ###
  # Get Source
  #
  # @param idx {Integer} The source index, if idx is not defined or null, return the current source index
  ###
  getSource: (idx) ->
    idx = idx || @currentSourceIndex
    return @sources[idx] if 0 <= idx < @sources.length
    return -1

  getCurrentSource: ->
    @getSource()

  getActiveSource: ->
    @getCurrentSource()

  getSourcesList: ()->
    @sources

  getSourceIndex: (sourceType) ->
    for source, idx in @sources
      return idx if source == sourceType
    null

  ###
  # Volume up
  #
  # Increase the volume level by 1
  ###
  volumeUp: ->
    @setVolume(@volume + 1)

  ###
  # Volume down
  #
  # Decrease the volume level by 1
  #
  # @return this
  ###
  volumeDown: ->
    @setVolume @volume - 1

  ###
  # Set the volume level
  #
  # @emit 'volumeChanged', this, volumeLevel
  #
  # @param {Integer} volumeLevel the level volume asked
  # @return this
  ###
  setVolume: (volumeLevel, emit) ->
    emit = true if emit is undefined
    if @volumeMin <= volumeLevel <= @volumeMax
      @volume = volumeLevel
      @emit 'volumeChanged', @, volumeLevel if emit
      # callback null, @, @volume
    else
      msg = "Could not decrease volume level under #{@volumeMin}" if volumeLevel < @volumeMin
      msg = "Could not increase volume level more than #{@volumeMax}" if volumeLevel > @volumeMax
      @logger.log msg if @logger
      # callback msg, @, @volume
    @

  getVolume: ->
    @volume

  ###
  # setStatus
  #
  # @param {STATUS}
  ###
  setStatus: (status, emit) ->
    emit = true if emit is undefined
    unless @status == status
      @status = status
      @emit 'statusChanged', @, status if emit
    @

  getStatus: ->
    @status

  ###
  # isPowerOn
  #
  # @return {Boolean} true if the emulator state is ON, otherwise false
  ###
  isPowerOn: ->
    @status == @STATUS.ON

  ###
  # isPowerOff
  #
  # @return {Boolean} true if the emulator state is OFF, otherwise false
  ###
  isPowerOff: ->
    @status == @STATUS.OFF

  ###
  # setPowerOn
  #
  # @return this
  ###
  setPowerOn: ->
    @setStatus @STATUS.ON

  ###
  # setPowerOff
  #
  # @return this
  ###
  setPowerOff: ->
    @setStatus @STATUS.OFF

  setScreenStatusOn: ->

  setScreenStatusOff: ->

  setScreenStatus: (status) ->

  getScreenStatus: ->

  isScreenOn: ->

  setMute: ->

  isMute: ->

  setLogger: (logger) ->
    @logger = logger
    @logger.log "Logger enabled"
    @

  getLogger: ->
    @logger

  setDebug: ->
    @debug = true

  unsetDebug: ->
    @debug = false

module.exports = BaseEmulator
