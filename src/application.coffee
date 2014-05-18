
class Reverser
  volume: 0
  tries: 10
  size: 5 # 6 is the max

  constructor: (@audioContext) ->
    @getUserMedia audio: true
    @pause = @reset

  getUserMedia: (options, callback = @gotStream) ->
    try
      navigator.getUserMedia =
        navigator.getUserMedia ||
        navigator.webkitGetUserMedia ||
        navigator.mozGetUserMedia
      navigator.getUserMedia options, callback, (e) -> alert('An error occured')
    catch e
      alert 'Looks like we can\'t access your mic'

  reverser: (audioProcessingEvent) =>
    e = audioProcessingEvent
    audioIn = e.inputBuffer.getChannelData(0)
    audioOut = e.outputBuffer.getChannelData(0)
    Array.prototype.reverse.call audioIn # from: http://stackoverflow.com/a/10973392

    for sample in [0..audioIn.length-1]
      audioOut[sample] = audioIn[sample] * @volume

  gotStream: (stream) =>
    # Create an AudioNode from the stream.
    @mediaStreamSource = @audioContext.createMediaStreamSource stream

  play: (size = @size) =>
    size = Math.pow(2, size) * 256
    if @mediaStreamSource?
      @reset()
      # see: https://developer.mozilla.org/en-US/docs/Web/API/ScriptProcessorNode
      # sizes:  256, 512, 1024, 2048, 4096, 8192 or 16384
      @processor = @audioContext.createScriptProcessor(size, 1, 1)

      # process using the reverser when the input buffer is full
      @processor.onaudioprocess = @reverser

      # connect mic stream -> processor (it will fire off an event when its buffer is full)
      @mediaStreamSource.connect @processor

      # connect processor -> speaker output
      @processor.connect @audioContext.destination

      @increaseVolume()
    else
      if @tries > 0
        @tries--
        setTimeout @play, 100
      else
        alert('Could not get audio stream')

  reset: ->
    return unless @processor? and @mediaStreamSource?
    @volume = 0
    @processor.onaudioprocess = null
    @processor.disconnect()
    @mediaStreamSource.disconnect()
    @processor = null
    delete @processor
    @tries = 10

  increaseVolume: =>
    if @volume < 1
      @volume += 0.1
      setTimeout @increaseVolume, 100

window.AudioContext = window.AudioContext || window.webkitAudioContext

reverser = new Reverser new AudioContext()
reverser.play()

