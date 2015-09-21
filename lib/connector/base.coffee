
EventEmitter = require('events').EventEmitter

class BaseConnector extends EventEmitter
  constructor: ->

  connect: ->

  ###
  # Override this method
  ###
  _write: (data) ->

  write: (data) ->
