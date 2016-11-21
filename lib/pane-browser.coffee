path = require 'path'
{CompositeDisposable} = require 'atom'
PaneElement = require './pane-element'
Pane = require './pane'
{isDummy} = require './helpers'

module.exports =
  config:
    minifyZoomLevel:
      type: 'number'
      title: 'Minify zoom level'
      defualt: 0.7
      minimum: 0.1
      maximum: 2.0

  activate: (state) ->
    @subscription = new CompositeDisposable()
    @subscription.add atom.commands.add 'atom-workspace',
      'Pane Browser: Open': => @open()
    @subscription.add atom.commands.add 'atom-workspace',
      'Pane Browser: Open from clipboard': => @open null, {clipboard: true}

    @elements = []
    @pane = new Pane()

    for pane in atom.workspace.getPanes()
      for item in pane.items
        if isDummy item.getTitle()
          @pane.add pane
          @subscription.add @pane.onDidAddItem pane
          @subscription.add @pane.onWillDestroy pane

          @open pane
          break

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

        paneElement = new PaneElement()
        @elements.push paneElement
        @pane.activeElement.appendChild paneElement.create
          textEditor: textEditor
          clipboard: opts.clipboard

    else
      textEditor = @pane.activePaneTextEditor
      @pane.setIndex textEditor

      paneElement = new PaneElement()
      @elements.push paneElement
      @pane.activeElement.appendChild paneElement.create
        textEditor: textEditor
        clipboard: opts.clipboard
