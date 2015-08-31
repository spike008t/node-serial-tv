BaseEmulator = require '../../lib/emulator/base'
sinon = require 'sinon'

describe "Base Emulator", ->
  emulator = null
  ee = null

  before ->
    emulator = new BaseEmulator {}
    emulator.setLogger console
    ee = sinon.stub emulator, 'emit'

  describe "Volume", ->

    beforeEach ->
      ee.reset()

    it "check if defaults values is correct", (done) ->
      assert.equal emulator.getVolume(), 10, "the default volume level is 10"
      assert.equal emulator.volumeMin, 0, "the default volume min level is 0"
      assert.equal emulator.volumeMax, 99, "the default volume max level is 99"
      done()

    describe "by calling volumeUp", ->

      it 'should emit the event volumeChanged with the new volume', (done) ->
        currentVolume = emulator.getVolume()
        newVolume = currentVolume + 1
        emulator.volumeUp()
        assert.equal emulator.getVolume(), newVolume
        assert.equal ee.calledWithExactly('volumeChanged', emulator, newVolume), true
        done()

    describe "by calling volumeDown", ->
      beforeEach ->
        ee.reset()

      it 'should emit the event volumeChanged with the new volume', (done) ->
        currentVolume = emulator.getVolume()
        newVolume = currentVolume - 1
        emulator.volumeDown()
        assert.equal emulator.getVolume(), newVolume
        assert.equal ee.calledWithExactly('volumeChanged', emulator, newVolume), true
        done()

      it 'should not emit the event volumeChanged if currentVolume is 0', (done)->
        currentVolume = emulator.getVolume()

        # reset volume to 0
        emulator.volume = 0
        emulator.volumeDown()
        assert.equal emulator.getVolume(), 0
        assert.equal ee.calledWithExactly("volumeChanged", emulator, 0), false
        emulator.volume = currentVolume

        done()

    describe "by setting custom value", ->
      it 'should emit the event volumeChanged with the new volume', (done) ->
        currentVolume = emulator.getVolume()
        newVolume = 10
        emulator.setVolume newVolume
        assert.equal emulator.getVolume(), newVolume
        assert.equal ee.calledWithExactly('volumeChanged', emulator, newVolume), true
        done()

  describe "Power Status", ->

    beforeEach ->
      ee.reset()

    it "check if defaults values is correct", (done) ->
      assert.equal emulator.isPowerOn(), false, "isPowerOn() must return false"
      assert.equal emulator.isPowerOff(), true, "isPowerOff() must return true"
      assert.equal emulator.getStatus(), emulator.STATUS.OFF, "the default volume max level is 99"
      done()

    describe "by calling setPowerOn()", ->
      before ->
        # must start with TV off
        emulator.status = emulator.STATUS.OFF

      beforeEach ->
        ee.reset()

      it 'should emit the event statusChanged with the new status ON', (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"
        assert.equal emulator.isPowerOff(), true, "The TV must be off"
        assert.equal emulator.isPowerOn(), false, "The TV must be off"
        emulator.setPowerOn()
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must be on"
        assert.equal ee.calledWithExactly('statusChanged', emulator, emulator.STATUS.ON), true
        done()

      it 'should not emit the event statusChanged if the TV is ON', (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must be on"
        assert.equal emulator.isPowerOff(), false, "The TV must be on"
        assert.equal emulator.isPowerOn(), true, "The TV must be on"
        emulator.setPowerOn()
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must still be on"
        assert.equal ee.called, false
        done()

    describe "by calling setPowerOff()", ->
      before ->
        # must start with TV on
        emulator.status = emulator.STATUS.ON

      beforeEach ->
        ee.reset()

      it 'should emit the event statusChanged with the new volume OFF', (done) ->
        assert.equal emulator.getStatus(), emulator.STATUS.ON, "The TV must be on"
        assert.equal emulator.isPowerOff(), false, "The TV must be on"
        assert.equal emulator.isPowerOn(), true, "The TV must be on"
        emulator.setPowerOff()
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"
        assert.equal ee.calledWithExactly('statusChanged', emulator, emulator.STATUS.OFF), true
        done()

      it 'should not emit the event statusChanged if the TV is OFF', (done)->
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"
        assert.equal emulator.isPowerOff(), true, "The TV must be off"
        assert.equal emulator.isPowerOn(), false, "The TV must be off"
        emulator.setPowerOff()
        assert.equal emulator.getStatus(), emulator.STATUS.OFF, "The TV must be off"
        assert.equal ee.called, false
        done()

  describe "Source", ->
    beforeEach ->
      ee.reset()

    it 'check if default source is NONE', (done) ->
      assert.equal emulator.getSource(), emulator.SOURCE_TYPE.NONE, "The default source must be on NONE"
      done()

    describe "when changing source", ->

      it 'should emit the event sourceChanged with the new source', (done) ->
        emulator.setSource emulator.SOURCE_TYPE.TV
        assert.equal emulator.getCurrentSource(), emulator.sources[emulator.SOURCE_TYPE.TV], "Current source idx must be at TV"
        assert.equal ee.calledWithExactly('sourceChanged', emulator, emulator.SOURCE_TYPE.TV, emulator.sources[emulator.SOURCE_TYPE.TV]), true, "Emit sourceChanged event with args: emulator, sourceIdx"
        done()
