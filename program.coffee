
@analyser = S.analyser()
analyser.fftSize = 2048
analyser.smoothingTimeConstant = 0.1

S.connect(analyser)

@osc = S.osc(400)
osc.start(0)
oscPlaying = false

oscNowPlaying = ->
  return unless oscPlaying
  oscString = "#{osc.type} wave @ #{Math.round(osc.frequency.value)} Hz"
  $('#now-playing').text(oscString)

startOsc = ->
  oscPlaying = true
  oscNowPlaying()
  F.stop()
  S.connect(osc, to: analyser)

stopOsc = ->
  oscPlaying = false
  osc.disconnect(0)

stopAll = ->
  stopOsc()
  S.stopSound()

inputToFreq = d3.scale.pow()
  .exponent(2)
  .domain([1,100])
  .range([100, 4000])

$ ->
  C.x.domain([1, analyser.frequencyBinCount])
  C.y.domain([analyser.minDecibels, analyser.maxDecibels])

  $("#volume").on "change", (e) ->
    newValue = +$(this).val()
    S.setVolume(newValue / 100.0)

  $("#file").on "change", (e) ->
    stopAll()
    F.handleSelect(e, list: $("#contents"))
    F.playAudio(connectTo: analyser)

  $('input#freq').on "change", ->
    newValue = +$(this).val()
    convertedValue = inputToFreq(newValue)
    osc.frequency.value = convertedValue
    oscNowPlaying()

  $('.osc-type').on "click", ->
    $('.osc-type').css('font-weight', 'normal')
    $(this).css('font-weight', 'bold')
    osc.type = +$(this).val()
    oscNowPlaying()

  $('#play-osc').on "click", ->
    stopAll()
    startOsc()

  $(document).on '.play-file', 'click', ->
    stopAll()

  $('#stop').on "click", ->
    stopOsc()

  $('.load-file').on "click", ->
    stopAll()
    fileName = $(this).data('file-name')
    $("#now-playing").text($(this).text())
    S.loadSound fileName, (buffer) ->
      S.playBuffer(buffer, connectTo: analyser, file: fileName)


@interval = setInterval ->
    freq = S.getFrequencyData(analyser)
    C.drawGraph(freq)
  , 200

kill = ->
 clearInterval interval
