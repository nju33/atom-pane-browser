{isDummy} = require './helpers'

module.exports = class Pane
  Object.defineProperty @prototype, 'activeElement',
    get: -> atom.views.getView @activeItem

  Object.defineProperty @prototype, 'activePaneIndex',
    get: ->
      for item, idx in @items
        if item is @activeItem
          break
      idx

  Object.defineProperty @prototype, 'activePaneTextEditor',
    get: ->
      @activeItem.activeItem

  constructor: ->
    @activeItem = null
    @items = []
    @usedIndex = []

  getFreeIndex: ->
    for i in [0..22]
      if i not in @usedIndex
        break

    @usedIndex.push i
    i

  setIndex: (textEditor) ->
    path = textEditor.getPath()
    matches = path.match /(\d+)$/
    if matches?
      @usedIndex.push Number matches[1]

  add: (pane) ->
    unless pane?
      activePane = atom.workspace.getActivePane()
      pane = @activeItem = activePane.splitRight()
      @items.push pane
    else
      @activeItem = pane

    @items.push pane
    @activeElement.style.position = 'relative'

    @activeItem

  onDidAddItem: (pane) ->
    pane.onDidAddItem ({item}) =>
      return if isDummy item.getTitle()

      itemPath = item.getPath()
      [firstPane] = atom.workspace.getPanes()
      len = firstPane.items.length

      if firstPane in @items
        leftPane = @activeItem.splitLeft()
        setTimeout =>
          @activeItem.moveItemToPane item, leftPane, 0
          leftPane.activate()
          leftPane.activateItemAtIndex 0
        , 0

      else
        setTimeout ->
          firstPaneItems = firstPane.getItems()
          exists = false
          for firstPaneItem, i in firstPaneItems
            if firstPaneItem.getPath() is itemPath
              firstPane.activate()
              firstPane.activateItemAtIndex i
              pane.destroyItem item
              exists = true
              break

          unless exists
            pane.moveItemToPane item, firstPane, len
            firstPane.activate()
            firstPane.activateItemAtIndex len
        , 0

  onWillDestroy: (pane) ->
    textEditor = pane.activeItem

    pane.onWillDestroy =>
      matches = textEditor.getTitle().match /(\d+)$/

      if matches
        fileIdx = matches[1]
        idx = @usedIndex.indexOf Number(fileIdx)
        if ~idx
          @usedIndex.splice idx, 1

      textEditor.deleteLine()
      textEditor.save()
