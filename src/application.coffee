window.AudioContext = window.AudioContext || window.webkitAudioContext
audioContext = new AudioContext()

getUserMedia = (options, callback) ->
  try
    navigator.getUserMedia =
      navigator.getUserMedia ||
      navigator.webkitGetUserMedia ||
      navigator.mozGetUserMedia
    navigator.getUserMedia options, callback, (e) -> alert('An error occured')
  catch e
    alert 'Looks like we can\'t access your mic'

reverser = (audioProcessingEvent) ->
  e = audioProcessingEvent
  audioIn = e.inputBuffer.getChannelData(0)
  audioOut = e.outputBuffer.getChannelData(0)
  Array.prototype.reverse.call audioIn # from: http://stackoverflow.com/a/10973392

  for sample in [0..audioIn.length-1]
    audioOut[sample] = audioIn[sample]

gotStream = (stream) ->
    # Create an AudioNode from the stream.
    mediaStreamSource = audioContext.createMediaStreamSource stream

    # see: https://developer.mozilla.org/en-US/docs/Web/API/ScriptProcessorNode
    # sizes:  256, 512, 1024, 2048, 4096, 8192 or 16384
    processor = audioContext.createScriptProcessor(8192, 1, 1)

    # process using the reverser when the input buffer is full
    processor.onaudioprocess = (audioProcessingEvent) -> reverser audioProcessingEvent

    # connect mic stream -> processor (it will fire off an event when its buffer is full)
    mediaStreamSource.connect processor

    # connect processor -> speaker output
    processor.connect audioContext.destination


getUserMedia audio: true, gotStream
