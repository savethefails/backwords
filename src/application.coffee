
class Reverser
  volume: 0
  tries: 10
  size: 8192 # sizes:  256, 512, 1024, 2048, 4096, 8192 or 16384

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
    sampleSize = @size-1
    for i in [0..sampleSize]
      audioOut[i] = audioIn[sampleSize - i]

  gotStream: (stream) =>
    # Create an AudioNode from the stream.
    @mediaStreamSource = @audioContext.createMediaStreamSource stream

  play: (size) =>
    @size = Math.pow(2, size) * 256 if size?
    if @mediaStreamSource?
      @reset()
      # see: https://developer.mozilla.org/en-US/docs/Web/API/ScriptProcessorNode
      @processor = @audioContext.createScriptProcessor(@size, 1, 1)
      @gainNode = @audioContext.createGain()
      @gainNode.gain.value = 0

      # process using the reverser when the input buffer is full
      @processor.onaudioprocess = @reverser

      # connect mic stream -> processor (it will fire off an event when its buffer is full)
      @mediaStreamSource.connect @processor

       # connect processor -> volume node
      @processor.connect @gainNode

      # volume node -> speaker output
      @gainNode.connect @audioContext.destination

      @changeVolume()
    else
      if @tries > 0
        @tries--
        setTimeout @play, 100
      else
        alert('Could not get audio stream')

  reset: ()->
    return unless @processor? and @mediaStreamSource?
    @changeVolume(0, 0, 0)
    @processor.onaudioprocess = null
    @processor.disconnect()
    @mediaStreamSource.disconnect()
    @processor = null
    delete @processor
    @tries = 10

  changeVolume: (start = 0, end = 1, time = 5) =>
    currentTime = @audioContext.currentTime;
    @gainNode.gain.linearRampToValueAtTime(start, currentTime)
    @gainNode.gain.linearRampToValueAtTime(end, currentTime + time)

window.AudioContext = window.AudioContext || window.webkitAudioContext

reverser = new Reverser new AudioContext()
reverser.play()

