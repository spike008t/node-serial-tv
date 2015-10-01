'use strict'

###
# Base class
#
# This class is the base class
###
class BaseClient
  constructor: (params)->
    @connector = params.connector

  setConnector: (connector) ->
    @connector = connector

  initListener: ->
    @connector.on 'data',

  removeListener: ->

  powerOn: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  powerOff: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  isPowerOn: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  setSource: (sourceType, cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  getSource: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  getPower: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  volumeUp: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  volumeDown: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  volumeLevel: (volumeLevel, cb)->
    cb = cb || (()->)
    throw "Not implemented"

  getVolume: (cb) ->
    cb = cb || (()->)
    throw "Not implemented"

  send: (data) ->
    @emit "send", data, @

modules.export = BaseClient
