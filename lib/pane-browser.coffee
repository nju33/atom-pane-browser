fs = require 'fs'
path = require 'path'
electron = require 'electron'
{CompositeDisposable} = require 'atom'
PaneElement = require './pane-element'
Pane = require './pane'
{isDummy} = require './helpers'

module.exports =
  config:
    defaultScale:
      type: 'number'
      title: 'Default scale size'
      default: 1.0
      minimum: 0.1
      maximum: 1.0
    minifyZoomLevel:
      type: 'number'
      title: 'Minify zoom level'
      default: 0.7
      minimum: 0.1
      maximum: 1.0
    ua:
      type: 'string'
      title: 'User agent'
      default: 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'

  activate: (state) ->
    @subscription = new CompositeDisposable()
    @subscription.add atom.commands.add 'atom-workspace',
      'Pane Browser: Open': => @open()
      'Pane Browser: Open from clipboard': => @open null, {clipboard: true}
      'Pane Browser: Reset all state': => @resetAllState()
    @subscription.add atom.commands.add 'atom-pane-browser',
      'Pane Browser: Reload': =>
          pane = atom.views.getView atom.workspace.getActivePane()
          paneBrowser = pane.querySelector '.atom-pane-browser__webview'

          if paneBrowser is null
            return

          paneBrowser.reload()
      'Pane Browser: Open devtool': =>
          pane = atom.views.getView atom.workspace.getActivePane()
          paneBrowser = pane.querySelector '.atom-pane-browser__webview'

          if paneBrowser is null
            return

          paneBrowser.openDevTools()
      'Pane Browser: Capture': => @capturePage 1
      'Pane Browser: Capture @2x': => @capturePage 2
      'Pane Browser: Capture @3x': => @capturePage 3

    @elements = []
    @pane = new Pane()

    for pane in atom.workspace.getPanes()
      item = pane.activeItem
      unless item?
        continue

      if isDummy item.getTitle()
        @pane.add pane
        @subscription.add @pane.onDidAddItem pane
        @subscription.add @pane.onWillDestroy pane
        @open pane

  deactivate: ->
    @subscription.dispose()
    for pane in @pane.items
      pane.destroy()
    for el in @elements
      el.removeAllEventListener()

  openFromClipboard: (pane) ->

  open: (pane, _opts) ->
    opts = Object.assign {}, {clipboard: false}, _opts

    unless pane?
      pane = @pane.add()
      @subscription.add @pane.onDidAddItem pane

      idx = @pane.getFreeIndex()
      filePath = path.resolve __dirname, "../dummy/atom-pane-browser#{idx}"
      atom.workspace.open filePath
      .then (textEditor) =>
        @subscription.add @pane.onWillDestroy pane

        textEditor.deleteLine()
        textEditor.save()

        paneElement = new PaneElement
          path: (atom.project.getPaths() || [''])[0]
          textEditor: textEditor
          clipboard: opts.clipboard
        @elements.push paneElement
        @pane.activeElement.appendChild paneElement.create()

    else
      textEditor = @pane.activePaneTextEditor
      @pane.setIndex textEditor

      paneElement = new PaneElement
        path: (atom.project.getPaths() || [''])[0]
        textEditor: textEditor
        clipboard: opts.clipboard
      @elements.push paneElement
      @pane.activeElement.appendChild paneElement.create()

  capturePage: (level) ->
    el = document.activeElement
    unless el.classList.contains 'atom-pane-browser__webview'
      return

    rect =
      x: 0
      y: 0
      width: el.clientWidth * level
      height: el.clientHeight * level

    el.capturePage rect, (nativeImg) ->
      picturesDirpath = electron.remote.app.getPath 'pictures'
      dirname = path.resolve picturesDirpath, 'pane-browser'

      try
        fs.accessSync dirname, fs.constants.F_OK
      catch err
        fs.mkdirSync dirname

      filepath = path.join dirname, "#{Date.now()}.png"
      png = nativeImg.toPNG()
      fs.writeFile filepath, png
      atom.notifications.addSuccess 'Captured',
        detail: filepath
        dismissable: true

  resetAllState: ->
    for i in [0..50]
      do (_i = i) ->
        filePath = path.resolve __dirname, "../dummy/atom-pane-browser#{_i}"
        fs.writeFile filePath, '', 'utf-8'
