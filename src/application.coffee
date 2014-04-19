window.AudioContext = window.AudioContext || window.webkitAudioContext
audioContext = new AudioContext()

getUserMedia = (options, callback) ->
  try
    navigator.getUserMedia = 
      navigator.getUserMedia ||
      navigator.webkitGetUserMedia ||
      navigator.mozGetUserMedia
    navigator.getUserMedia options, callback, ->
  catch e
    alert 'getUserMedia threw exception :' + e


gotStream = (stream) ->
    # Create an AudioNode from the stream.
    mediaStreamSource = audioContext.createMediaStreamSource stream

    # Connect it to the destination to hear yourself (or any other node for processing!)
    mediaStreamSource.connect audioContext.destination


getUserMedia audio: true, gotStream
