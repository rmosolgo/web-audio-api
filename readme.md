# Web Audio API

This goofy app lets you:

- upload local files to the browser, then play them in the browser with the JavaScript Web Audio API
- play an oscillator from the Web Audio API
- load a sound from the server and play it with JavaScript

The sounds are analyzed in a little bar chart underneath (with an `analyserNode`).

Live on [Heroku](http://rdm-audio.herokuapp.com/).


__`/lib/audio.coffee`__ handles loading files from the server and starting and stopping buffers.


__`/lib/file.coffee`__  handles working with `File` & `FileReader` objects to list them on the page and play them with the code from `audio.coffee`.

__`/lib/chart.coffee`__ provides the chart for the analyser node

__`/program.coffee`__ is a sloppy mess to tie it all together.

 [screenshot](https://github.com/rmosolgo/web-audio-api/blob/master/screenshot.png)

