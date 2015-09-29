
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
        response = "a 00 OK00x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        done()

      it "Check if when asking tv state on ON, it return ON", (done) ->
        emulator.setPowerOn()
        cmd = "ka 00 FF\r"
        response = "a 00 OK01x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        done()

    describe "when TV is OFF", ->
      beforeEach ->
        cb = sinon.spy()
        ee.reset()
        emulator.status =  emulator.STATUS.OFF

      it "Check if asking power ON works", (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"

        cmd = "ka 00 01\r"
        response = "a 00 OK01x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        assert.equal emulator.isPowerOn(), true, "The TV must be on"
        done()

      it "Check if asking power OFF works", (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"

        cmd = "ka 00 00\r"
        response = "a 00 OK00x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        assert.equal emulator.isPowerOff(), true, "The TV must be OFF"
        done()

    describe "when TV is ON", ->
      beforeEach ->
        cb = sinon.spy()
        ee.reset()
        emulator.status =  emulator.STATUS.ON

      it "Check if asking power ON works", (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must be ON"

        cmd = "ka 00 01\r"
        response = "a 00 OK01x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        assert.equal emulator.isPowerOn(), true, "The TV must be on"
        done()

      it "Check if asking power OFF works", (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must be ON"

        cmd = "ka 00 00\r"
        response = "a 00 OK00x\r"
        emulator.process cmd, cb
        assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
        assert.equal emulator.isPowerOff(), true, "The TV must be OFF"
        done()

    it "Check if an invalid command return error", (done) ->
      cmd = "ka 00 02\r"
      response = "a 00 NG01x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
      done()

  describe "command kb", ->
    beforeEach ->
      cb = sinon.spy()
      ee.reset()

    it "Change source to HDMI1", (done) ->
      # force source index to TV
      emulator.currentSourceIndex = 1

      cmd = "kb 00 08\r"
      response = "b 00 OK08x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
      assert.equal emulator.getActiveSource(), emulator.SOURCE_TYPE.HDMI, true, "The current source must be HDMI"
      assert.equal ee.calledWithExactly('sourceChanged', emulator, emulator.sourcesMappingLegacy[8], emulator.SOURCE_TYPE.HDMI), true, "An event 'sourceChanged' must be emitted"
      done()

    it "Change source to HDMI2", (done) ->
      # force source index to TV
      emulator.currentSourceIndex = 1

      cmd = "kb 00 09\r"
      response = "b 00 OK09x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match with #{response}"
      assert.equal emulator.getActiveSource(), emulator.SOURCE_TYPE.HDMI, true, "The current source must be HDM2"
      assert.equal ee.calledWithExactly('sourceChanged', emulator, emulator.sourcesMappingLegacy[9], emulator.SOURCE_TYPE.HDMI), true, "An event 'sourceChanged' must be emitted"
      done()

    it "Change to unknown source must response an error", (done) ->
      emulator.currentSourceIndex = 1

      cmd = "kb 00 10\r"
      response = "b 00 NG01x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match with #{response}"
      assert.equal emulator.getActiveSource(), emulator.sources[1], "The current source hasn't changed"
      assert.equal ee.called, false, "No event must be trigged"
      done()

  describe "command xb", ->
    beforeEach ->
      cb = sinon.spy()
      ee.reset()

    before ->
      # emulator.setLogger console


    it "Change source to HDMI1", (done) ->
      # force source index to TV
      emulator.currentSourceIndex = 1

      cmd = "xb 00 90\r"
      response = "b 00 OK90x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match"
      assert.equal emulator.getActiveSource(), emulator.SOURCE_TYPE.HDMI, "The current source must be HDMI"
      assert.equal ee.calledWithExactly('sourceChanged', emulator, emulator.sourcesMappingLegacy[8], emulator.SOURCE_TYPE.HDMI), true, "An event 'sourceChanged' must be emitted"
      done()

    it "Change source to HDMI2", (done) ->
      # force source index to TV
      emulator.currentSourceIndex = 1

      cmd = "xb 00 91\r"
      response = "b 00 OK91x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match with #{response}"
      assert.equal emulator.getActiveSource(), emulator.SOURCE_TYPE.HDMI, "The current source must be HDM2"
      assert.equal ee.calledWithExactly('sourceChanged', emulator, emulator.sourcesMappingLegacy[9], emulator.SOURCE_TYPE.HDMI), true, "An event 'sourceChanged' must be emitted"
      done()

    it "Change to unknown source must response an error", (done) ->
      emulator.currentSourceIndex = 1

      assert.equal emulator.getActiveSource(), emulator.sources[1], true, "Assert that current source is idx 1 before test"

      cmd = "xb 00 99\r"
      response = "b 00 NG02x\r"
      emulator.process cmd, cb
      assert.equal cb.calledWith(null, emulator, response), true, "The response must match with #{response}"
      assert.equal emulator.getActiveSource(), emulator.sources[1], "The current source hasn't changed"
      assert.equal ee.called, false, "No event must be trigged"
      done()
