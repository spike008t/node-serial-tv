BaseEmulator = require '../../lib/emulator/base'
sinon = require 'sinon'

describe "Base Emulator", ->
  emulator = null
  ee = null

  before ->
    emulator = new BaseEmulator {}
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

  describe "Source", ->
    beforeEach ->
      ee.reset()

    it 'check if default source is NONE', (done) ->
      assert.equal emulator.getSource(), emulator.SOURCE_TYPE.NONE, "The default source must be on NONE"
      done()

    describe "when changing source", ->

      it 'should emit the event sourceChanged with the new source', (done) ->
        emulator.setSource 1
        assert.equal emulator.getCurrentSource(), emulator.sources[1], "Current source idx must be at 1"
        assert.equal ee.calledWithExactly('sourceChanged', emulator, 1, emulator.sources[1]), true, "Emit sourceChanged event with args: emulator, sourceIdx"
        done()
