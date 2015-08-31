
Samsungv2 = require '../../lib/emulator/samsungv2'
sinon = require 'sinon'

describe "Samsung v2 emulator", ->
  emulator = null
  ee = null
  cb = null

  before ->
    emulator = new Samsungv2()
    emulator.setDebug()
    # emulator.setLogger console
    ee = sinon.stub emulator, 'emit'
    cb = sinon.spy()

  describe "isValid()", ->
    it "Check if a valid command is valid", (done) ->
      cmd = new Buffer [0x58, 0x80, 0x01, 0x01, 0x80, 0x5a]
      assert.equal emulator.isValid(cmd, cb), true, "0x58 0x80 0x01 0x01 0x80 0x5a must be treated as a valid command"
      assert.equal cb.calledWith(null), true, "Assert that callback was called with null"
      done()

    it "Check if isValid can handle a string", (done) ->
      cmd = new Buffer [0x58, 0x80, 0x01, 0x01, 0x80, 0x5a]
      assert.equal emulator.isValid(cmd.toString('hex'), cb), true, "0x58 0x80 0x01 0x01 0x80 0x5a as string must be treated as a valid command"
      assert.equal cb.calledWith(null), true, "Assert that callback was called with null"
      done()

    it "Check if an unknown command is not valid", (done) ->
      cmd = new Buffer [0x58, 0x80, 0x40, 0x01, 0x80, 0x99]
      assert.equal emulator.isValid(cmd), false, "The command is not defined"
      done()


  describe "createResponse", ->

    it "create a valid response must be valid and have a correct checksum", (done) ->
      # example form samsung doc:  58 80 01 01 80 5a
      #
      response = emulator._createCommand 0x80, 0x01, [0x80]
      assert.equal response.length, 6, 'Lenght of the response must be 6'
      assert.equal response[0], 0x58, 'The first byte must be 0x58'
      assert.equal response[response.length - 1], 0x5a, 'The checksum must be 0x5a'
      assert.equal emulator.isValid(response, cb), true, 'The parser must valid the command created by emulator itself'
      assert.equal cb.calledWith(null), true, "Assert that callback was called with null"
      done()

  describe "Commands 0x00", ->
    it "Check if 0x00 is accepted and return TV OFF", (done) ->
      emulator.setPowerOff()
      cmd = emulator._createCommand 0x80, 0x00, []
      response = emulator._createCommand 0x00, 0x01, [0x00, 0x00, 0x00, 0x00], 0x00
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
      done()

    it "Check if 0x00 is accepted and return TV ON when TV is ON", (done) ->
      emulator.setPowerOn()
      cmd = emulator._createCommand 0x80, 0x00, []
      response = emulator._createCommand 0x00, 0x01, [(1 << 4), 0x00, 0x00, 0x00], 0x00
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
      done()

  describe "Commands 0x01", ->

    beforeEach ->
      ee.reset()

    it "Check if accepted", (done) ->
      cmd = emulator._createCommand 0x80, 0x01, [0x00]
      emulator.process cmd, cb
      assert.equal cb.calledWithExactly(null), true, "Callback must be called"
      done()

    it "Check if power on works when the TV is OFF", (done) ->
      emulator.setPowerOff()

      assert.equal emulator.isPowerOff(), true, "The TV must be off before to start the test"
      cmd = emulator._createCommand 0x80, 0x01, [(1 << 7)]
      response = emulator._createCommand 0x00, 0x00, [0x01]
      emulator.process cmd, cb
      assert.equal cb.calledWithExactly(null, emulator, response), true
      assert.equal emulator.isPowerOn(), true
      assert.equal ee.calledWithExactly('statusChanged', emulator, emulator.STATUS.ON), true
      done()

    it "Check if power off works when the TV is ON", (done) ->
      emulator.setPowerOn()

      assert.equal emulator.isPowerOn(), true, "The TV must be off before to start the test"
      cmd = emulator._createCommand 0x80, 0x01, [0x0]
      response = emulator._createCommand 0x00, 0x00, [0x01]
      emulator.process cmd, cb
      assert.equal cb.calledWithExactly(null, emulator, response), true
      assert.equal emulator.isPowerOff(), true
      assert.equal ee.calledWithExactly('statusChanged', emulator, emulator.STATUS.OFF), true
      done()
