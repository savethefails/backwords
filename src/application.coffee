class Reverser
  sampleSize = 8192
  stream = null
  mediaStreamSource = null
  processor = null
  wetGain = null
  dryGain = null
  mixerGain = null
  audioContext = null

  getUserMedia = (options, callback) ->
    try
      navigator.getUserMedia =
        navigator.getUserMedia ||
        navigator.webkitGetUserMedia ||
        navigator.mozGetUserMedia
      navigator.getUserMedia options, callback, (e) -> alert('An error occured')
    catch e
      alert 'Looks like we can\'t access your mic'

  reverser = (audioProcessingEvent) =>
    e = audioProcessingEvent
    audioOut = e.outputBuffer.getChannelData(0)
    audioIn  = e.inputBuffer.getChannelData(0)
    for i in [0..sampleSize]
      audioOut[i] = audioIn[sampleSize - i]

  gotStream = (_stream) =>
    stream = _stream
    start()
    $('body').addClass('started')

  start = (size = 5) =>
    size = 6 if size > 6
    size = 4 if size < 4
    sampleSize = Math.pow(2, size) * 256
    reset()

    createNodes()
    connectNodes()

  createNodes = =>
    # Create an AudioNode from the stream.
    mediaStreamSource ?= audioContext.createMediaStreamSource stream

    # see: https://developer.mozilla.org/en-US/docs/Web/API/ScriptProcessorNode
    processor = audioContext.createScriptProcessor(sampleSize, 1, 1)
    # process using the reverser when the input buffer is full
    processor.onaudioprocess = reverser

    mixerGain ?= audioContext.createGain()
    mixerGain.gain.value = 0

    wetGain ?= audioContext.createGain()
    wetGain.gain.value = 0

    dryGain ?= audioContext.createGain()
    dryGain.gain.value = 1

  connectNodes = =>
    # connect mic stream -> processor (it will fire off an event when its buffer is full)
    mediaStreamSource.connect processor

     # connect processor -> wet volume node
    processor.connect wetGain

    # wet volume -> mixer volume
    wetGain.connect mixerGain

    # mic stream -> dry volume
    mediaStreamSource.connect dryGain

    # dry volume to mixer volume
    dryGain.connect mixerGain

    # mixer volume -> speaker output
    mixerGain.connect audioContext.destination

    changeVolume(1, 0.1, mixerGain)

  reset = ->
    return unless mixerGain?
    changeVolume(0, 0, mixerGain)
    if processor?
      processor.onaudioprocess = null
      processor.disconnect()
      processor = null
    if mediaStreamSource?
      mediaStreamSource.disconnect()

  changeVolume = (value = 1, delay = 1, node, ramp = 'linearRampToValueAtTime') =>
      currentTime = audioContext.currentTime
      node.gain[ramp](node.gain.value, currentTime)
      node.gain[ramp](value, currentTime + delay)

  crossFade = (quieteningNode, loudeningNode, delay = 1) =>
    return unless quieteningNode? and loudeningNode?
    changeVolume(0, delay, quieteningNode)
    changeVolume(1, delay, loudeningNode)

  constructor: ->
    AudioContextClass = window.AudioContext || window.webkitAudioContext
    audioContext = new AudioContextClass()
    getUserMedia audio: true, gotStream

  pause: -> reset.apply @, arguments

  play: -> start.apply @, arguments

  reversify: ->
    crossFade(dryGain, wetGain, 5)
    return true

  normalize: ->
    crossFade(wetGain, dryGain, 1)
    return true


$ ->
  reverser = null
  $('#start').click (e) ->
    e.preventDefault()
    return if reverser?
    reverser = new Reverser()
    return false

  $('#reverse-control').click (e) ->
    e.preventDefault()
    el = $(this)
    reversified = el.hasClass('on')

    el.toggleClass('on', !reversified)

    if reversified
      reverser.normalize()
    else
      reverser.reversify()


    return false


