@SOUNDS =
  keys: "/keys.mp3"
  kick: "/kick.wav"
  snare: "/snare.wav"
  song: "/song.mp3"

@BUFFERS = {}
@SOURCES = {}

window.AudioContext = window.AudioContext || window.webkitAudioContext

@S =
  context: new AudioContext

  loadSound: (url, callback) ->
    buffer = BUFFERS[url]
    if !buffer?
      request = new XMLHttpRequest
      request.open('GET', url, true)
      request.responseType = 'arraybuffer'
      request.onload = =>
        @context.decodeAudioData request.response, (buffer) ->
          BUFFERS[url] = buffer
          callback?(buffer)
      request.send()
    else
      callback?(buffer)

  playBuffer: (buffer, {at, file}) ->
    at ?= @context.currentTime
    if file?
      SOURCES[file] ?= {}
      source = SOURCES[file][at] ?= @context.createBufferSource()
    else
      source = @context.createBufferSource()
    source.buffer = buffer
    source.connect(@gainNode)
    #console.log "starting #{file} at #{at}"
    source.start(at)

  playSound: (file, {at}={}) ->
    console.log "playing #{file} at #{at}"
    @loadSound file, (buffer) =>
      @playBuffer(buffer, {at: at, file: file})

  stopSound: (file, {at}={}) ->
    at ?= @context.currentTime
    for started_at, buffer of SOURCES[file]
      buffer.stop(at)
      delete(SOURCES[file][started_at])

  setVolume: (volume) ->
    @gainNode.gain.value = volume

  init: ->
    @gainNode = @context.createGain()
    @filter = @context.createBiquadFilter()

    @gainNode.connect(@filter)
    @filter.connect(@context.destination)


  osc: (freq) ->
    oscillator = @context.createOscillator()
    oscillator.frequency.value = freq
    oscillator

  analyser: ->
    an = @context.createAnalyser()

  getFrequencyData: (analyser) ->
    frequencyData = new Float32Array(analyser.frequencyBinCount)
    analyser.getFloatFrequencyData(frequencyData)
    frequencyData

  getFrequencyValue: (analyser, frequency) ->
    data = @getFrequencyData(analyser)
    nyquist = @context.sampleRate/2
    index = Math.round(frequency/nyquist * data.length)
    data[index]

  connect: (node, {to}={}) ->
    to ?= @context.destination
    console.log "connecting #{node.constructor.name} to #{to.constructor.name}"
    node.connect(to)

S.init()
