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

  decodeAndPlay: (audioData, options={}) ->
    options.file ?= "decoded"
    @context.decodeAudioData audioData, (buffer) =>
      BUFFERS[options.file] = buffer
      @playBuffer(buffer, options)

  playBuffer: (buffer, {at, file, connectTo}={}) ->
    connectTo ?= @gainNode
    at ?= @context.currentTime
    if file?
      SOURCES[file] ?= {}
      source = SOURCES[file][at] ?= @context.createBufferSource()
    else
      source = @context.createBufferSource()
    source.buffer = buffer
    @connect(source, to: connectTo)
    source.start(at)

  playSound: (file, {at}={}) ->
    @loadSound file, (buffer) =>
      @playBuffer(buffer, {at: at, file: file})

  stopSound: (file, {at}={}) ->
    at ?= @context.currentTime
    if file?
      for started_at, buffer of SOURCES[file]
        buffer.stop(at)
        delete(SOURCES[file][started_at])
    else
      for file, buffers of SOURCES
        @stopSound(file,{at: at})

  setVolume: (volume) ->
    @gainNode.gain.value = volume

  init: ->
    @gainNode = @context.createGain()
    @connect(@gainNode, to: @context.destination)

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
    to ?= @gainNode
    console.log "connecting #{node.constructor.name} to #{to.constructor.name}"
    node.connect(to)

S.init()
