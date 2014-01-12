
@analyser = S.analyser()
analyser.fftSize = 512
analyser.smoothingTimeConstant = 0.1

S.connect(analyser)

$ ->
  $("#file").on "change", (e) ->
    F.handleSelect(e, list: $("#contents"))
    F.playAudio(connectTo: analyser)


# @osc = S.osc(400)


# S.connect(osc, to: analyser)
# S.connect(analyser)

# osc.start(0)

inputToFreq = d3.scale.pow()
  .exponent(2)
  .domain([1,100])
  .range([100, 8000])

$ ->
  C.x.domain([1, analyser.frequencyBinCount])
  C.y.domain([analyser.minDecibels, analyser.maxDecibels])

  # $('input#freq').on "change", ->
  #   newValue = +$(this).val()
  #   convertedValue = inputToFreq(newValue)
  #   osc.frequency.value = convertedValue

  # $('.osc-type').on "click", ->
  #   $('.osc-type').css('font-weight', 'normal')
  #   $(this).css('font-weight', 'bold')
  #   osc.type = +$(this).val()

registerFrequencies = ->
  freq = S.getFrequencyData(analyser)
  C.drawGraph(freq)

@interval = setInterval registerFrequencies, 200

kill = ->
 clearInterval interval
