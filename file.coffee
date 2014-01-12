dataURIToBlob = (dataURI) ->
  byteString = atob(dataURI.split(",")[1])
  mimeString = dataURI.split(",")[0].split(':')[1].split(';')[0]
  ab = new ArrayBuffer(byteString.length);
  ia = new Uint8Array(ab);
  for i in [0..byteString.length]
    ia[i] = byteString.charCodeAt(i)

  bb = new BlobBuilder();
  bb.append(ab);
  bb.getBlob(mimeString)

@F =
  isSupported: () ->
    !!(window.File && window.FileList && window.FileReader && window.Blob)
  init: ->
    if @isSupported()
      console.log "File is supported"
    else
      alert "Your browser doesn't support file streaming -- try the latest version of Chrome!"

    $(document).on "click", ".add-to-playlist", (e) =>
      playlistId = $(e.target).data("playlist-id")
      console.log "adding #{playlistId}"
      file = @staged[playlistId]
      @addToPlaylist(file, playlistId)

    $(document).on "click", ".remove-from-playlist", (e) =>
      playlistId = $(e.target).data("playlistId")
      console.log "removing #{playlistId}"
      @removeFromPlaylist(playlistId)

    $(document).on "click", ".play-file", (e) =>
      playlistId = $(e.target).data("playlistId")
      @playAudio(playlistId: playlistId, connectTo: analyser)

    $('#stop').on "click", (e) ->
      $('#now-playing').text("(nothing)")
      S.stopSound("decoded")

  staged: {}

  handleSelect: (evt, {list}={}) ->
    @list ?= list
    @currentFiles = evt.target.files
    @staged = {}
    console.log "this #{@currentFiles.constructor.name} has #{@currentFiles.length} #{@currentFiles[0]?.constructor.name}#{if @currentFiles.length != 1 then "s" else ""} in it"
    if @list?
      html = for f in @currentFiles
        playlist_id = "#{f.name}-#{(new Date).getTime()}"
        @staged[playlist_id] = f
        "<li data-playlist-id='#{playlist_id}'>
          <strong>#{f.name}:</strong>
          #{f.type || "n/a"} - #{f.size} bytes, last modified at #{f.lastModifiedDate?.toLocaleDateString()}
          <!-- button data-playlist-id='#{playlist_id}' class='add-to-playlist'>Add to Playlist</button -->
          <button data-playlist-id='#{playlist_id}' class='play-file'>Play</button>
        </li>"
      html = html.join("")
      @list.html(html)

  playAudio: (options={}) ->
    S.stopSound("decoded")
    if options.playlistId
      options.fileObject = @staged[options.playlistId] || @playlist[options.playlistId]
    options.fileObject ?= @currentFiles[0]
    $("#now-playing").text(options.fileObject.name)
    reader = new FileReader
    reader.onload = (readEvent) ->
      S.decodeAndPlay(readEvent.target.result, options)

    if options.fileObject.dataURL
      blob = dataURIToBlob(options.fileObject.dataURL)
      reader.readAsArrayBuffer(options.fileObject)
    else
      reader.readAsArrayBuffer(options.fileObject)

  addToPlaylist: (file, playlistId, addToArray=true) ->
    if addToArray
      @playlist.push {file: file, playlistId: playlistId}
      @playlist[playlistId] = file
      delete @staged[playlistId]
      @list.find("li[data-playlist-id='#{playlistId}']").remove()

    song_html = "<li>
      <strong>#{file.name}</strong>
      <button data-playlist-id='#{playlistId}' class='play-file'>Play</button>
      <button data-playlist-id=#{playlistId} class='remove-from-playlist'>Remove</button>
      </li>"
    $("#playlist").append(song_html)

    if addToArray
      @savePlaylist()

  removeFromPlaylist: (playlistId) ->
    songs = @playlist.filter (f) -> f.playlistId == playlistId
    for s in songs
      index = @playlist.indexOf(s)
      @playlist.splice(index, 1)
    $(".remove-from-playlist[data-playlist-id='#{playlistId}'").slideUp( -> $(this).remove())

  savePlaylist: ->
    console.log "saving", @playlist
    for f, idx in @playlist
      console.log "considering ##{idx}", f
      if !f.dataURL?
        @saveSong(f)

  saveSong: (file, idx) ->
    console.log "saving at #{idx}", file
    reader = new FileReader
    reader.onload = ->
      dataURL = reader.result
      file.dataURL = dataURL
      localStorage.setItem "rdm-playlist", JSON.stringify(@playlist)
    reader.readAsDataURL(file)

$ ->
  F.init()
