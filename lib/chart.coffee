
C =
  CONTAINER: "#audio-chart"
  barMargin: 2
  init: ->
    @svg = d3.selectAll(@CONTAINER).append('svg')
      .attr('width', "#{@width()}px")
      .attr('height', "#{@height()}px")

    @chart = @svg.append('g')
      .attr('class', 'chart')

    @x = d3.scale.linear()
      .domain([0, 0])
      .range([0, @width()])

    @y = d3.scale.linear()
      .domain(['min', 'max'])
      .range([@height(), 0])

    @color = d3.scale.linear()
      .domain([0, 100])
      .range(['blue', 'red', 'yellow'])

  width: ->
    $(@CONTAINER).width()
  height: ->
    250

  drawGraph: (freqArray) ->
    data = Array.prototype.slice.call(freqArray)
    barWidth = (@width() / (data.length + data.length * @barMargin))
    # console.log(data, barWidth)
    @color.domain([1, data.length/2, data.length])

    bars = @chart.selectAll('.freq-bar')
      .data(data)

    bars.enter().append('rect')
      .attr('class', 'freq-bar')
      .attr('x', (d, i) => @x(i+1))
      .attr('width', "#{barWidth}px")
      .attr('fill', (d, i) => @color(i+1))

    bars
      .attr('y', (d, i) => @y(d))
      .attr('height',(d, i) => d3.max([0, @height() - @y(d)]))

$ ->
  C.init()
