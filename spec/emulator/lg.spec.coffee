
LgEmulator = require '../../lib/emulator/lg'
sinon = require 'sinon'

describe "Lg emulator", ->
  emulator = null
  ee = null
  cb = null

  before ->
    emulator = new LgEmulator()
    emulator.setDebug()
    # emulator.setLogger console
    ee = sinon.stub emulator, 'emit'
    cb = sinon.spy()

  it "created without any problem", (done) ->
    assert.equal emulator instanceof LgEmulator, true, "typeof emulator must be LgEmulator but #{typeof emulator} given"
    done()

  describe "isValid()", ->
    beforeEach ->
      cb = sinon.spy()

    it "Check if a valid command is valid", (done) ->
      cmd = new Buffer "ka 00 FF\r"
      assert.equal emulator.isValid(cmd, cb), true, "ka 00 ff<CR> must be considered as a valid command"
      assert.equal cb.calledWith(null), true, "Assert that callback was called with null"
      done()

    it "Check if an unknown command is not valid", (done) ->
      cmd = new Buffer "aa 00 FF\r"
      assert.equal emulator.isValid(cmd, cb), false, "ka 00 ff<CR> must be considered as a valid command"
      assert.equal cb.calledWith(null), false, "Assert that callback was called with a non null argument"
      done()

  describe "command ka", ->
    beforeEach ->
      cb = sinon.spy()
      ee.reset()

    describe "with FF argument", ->

      beforeEach ->
        cb = sinon.spy()
        ee.reset()

      it "Check if when asking tv state on OFF, it return OFF", (done) ->
        emulator.setPowerOff()
        cmd = "ka 00 FF\r"
        response = "a 00 OK0x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        done()

      it "Check if when asking tv state on ON, it return ON", (done) ->
        emulator.setPowerOn()
        cmd = "ka 00 FF\r"
        response = "a 00 OK1x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        done()
