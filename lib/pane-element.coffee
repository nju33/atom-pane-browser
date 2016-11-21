paneBrowser = require './pane-browser-element'

module.exports = class PaneElement
  constructor: ->
    @minifyZoomLevel = atom.config.get 'pane-browser.minifyZoomLevel'
    atom.config.onDidChange 'pane-browser.minifyZoomLevel', (val) =>
      @minifyZoomLevel = val

  create: ({textEditor, clipboard}) ->
    element = @createRoot [
      @createMenu [
        @createBackBtn()
        @createForwardBtn()
        @createReloadBtn()
        @createOmni()
        @createGlass()
        @createDevtoolBtn()
      ]
      @createWebview textEditor, clipboard
    ]

    removeEventListeners = @eventListener textEditor
    @removeAllEventListener = ->
      rel() for rel in removeEventListeners

    element

  createRoot: (children) ->
    element = new (paneBrowser)()
    element.className = 'atom-pane-browser__box'
    for node in children
      element.appendChild node
    element

  createMenu: (children) ->
    menu = document.createElement 'div'
    menu.className = 'atom-pane-browser__menu'
    for node in children
      menu.appendChild node
    menu

  createBackBtn: ->
    @back = document.createElement 'div'
    @back.className = 'atom-pane-browser__back-btn atom-pane-browser__btn--disabled'
    @back

  createForwardBtn: ->
    @forward = document.createElement 'div'
    @forward.className = 'atom-pane-browser__forward-btn atom-pane-browser__btn--disabled'
    @forward

  createReloadBtn: ->
    @reload = document.createElement 'div'
    @reload.className = 'atom-pane-browser__reload-btn'
    @reload

  createOmni: ->
    @omni = document.createElement 'input'
    @omni.className = 'atom-pane-browser__omni native-key-bindings'
    @omni

  createGlass: ->
    @glass = document.createElement 'div'
    @glass.innerHTML = '<span class="atom-pane-browser__glass-inner"></span>'
    @glass.className = 'atom-pane-browser__glass--minify'
    @glass

  createDevtoolBtn: ->
    @devtool = document.createElement 'div'
    @devtool.className = 'atom-pane-browser__devtool-btn'
    @devtool

  createWebview: (textEditor, clipboard) ->
    @webview = document.createElement('webview');
    @webview.className = 'atom-pane-browser__webview native-key-bindings'
    @webview.src = clipboard && @getClipboardTextAndAdjust(clipboard) ||
                   textEditor.getText() ||
                   'https://www.google.com/'
    @webview.style.height = 'calc(100% - 38px)'
    @webview

  getClipboardTextAndAdjust: (clipboard) ->
    false unless clipboard

    text = atom.clipboard.read()
    @adjustOmniText text

  adjustOmniText: (text) ->
    if /https?:\/\//.test text
      text
    else if /^\d{4,}/.test text
      number = text.match(/(^\d{4,})/)[1]
      "http://localhost:#{number}"
    else if /[^.]+\.[^.]/.test text
      "http://#{text}"
    else
      "https://www.google.com/search?q=#{text}"

  eventListener: (textEditor) ->
    removeEventListeners = []

    handleDomReady = =>
      url = @webview.getURL()
      if /http:\/\//.test url
        url = url.replace /http:\/\//, ''
      @omni.value = url

      textEditor.deleteLine()
      textEditor.setText url
      textEditor.save()

      if @webview.canGoBack()
        @back.className = 'atom-pane-browser__back-btn'
      else
        @back.className = 'atom-pane-browser__back-btn atom-pane-browser__btn--disabled'

      if @webview.canGoForward()
        @forward.className = 'atom-pane-browser__forward-btn'
      else
        @forward.className = 'atom-pane-browser__forward-btn atom-pane-browser__btn--disabled'
    @webview.addEventListener 'dom-ready', handleDomReady
    removeEventListeners.push @webview.removeEventListener.bind @webview, 'dom-ready', handleDomReady

    handleOmniFocus = (e) -> e.target.select()
    @omni.addEventListener 'focus', handleOmniFocus
    removeEventListeners.push @omni.removeEventListener.bind @omni, 'focus', handleOmniFocus

    handleOmniKeydown = (e) =>
      if (e.keyCode is 13)
        @webview.loadURL @adjustOmniText e.target.value
        # if /https?:\/\//.test uri
        #   @webview.loadURL uri
        # else if /^\d{4,}/.test uri
        #   number = uri.match(/(^\d{4,})/)[1]
        #   @webview.loadURL "http://localhost:#{number}"
        # else if /[^.]+\.[^.]/.test uri
        #   @webview.loadURL "http://#{uri}"
        # else
        #   @webview.loadURL "https://www.google.com/search?q=#{uri}"
    @omni.addEventListener 'keydown', handleOmniKeydown
    removeEventListeners.push @omni.removeEventListener.bind @omni, 'keydown', handleOmniKeydown

    handleBackClick = (e) =>
      if @webview.canGoBack()
        @webview.goBack()
    @back.addEventListener 'click', handleBackClick
    removeEventListeners.push @back.removeEventListener.bind @back, 'click', handleBackClick

    handleForwardClick = (e) =>
      if @webview.canGoForward()
        @webview.goForward()
    @forward.addEventListener 'click', handleForwardClick
    removeEventListeners.push @forward.removeEventListener.bind @forward, 'click', handleForwardClick

    handleReloadClick = (e) => @webview.reload()
    @reload.addEventListener 'click', handleReloadClick
    removeEventListeners.push @reload.removeEventListener.bind @reload, 'click', handleReloadClick

    handleGlass = (e) =>
      if @glass.classList.contains 'atom-pane-browser__glass--minify'
        @webview.setZoomFactor 0.7
        @glass.className = 'atom-pane-browser__glass--magnify'
      else
        @webview.setZoomFactor 1
        @glass.className = 'atom-pane-browser__glass--minify'
    @glass.addEventListener 'click', handleGlass
    removeEventListeners.push @glass.removeEventListener.bind @glass, 'click', handleGlass

    handleDevtoolClick = (e) => @webview.openDevTools()
    @devtool.addEventListener 'click', handleDevtoolClick
    removeEventListeners.push @devtool.removeEventListener.bind @devtool, 'click', handleDevtoolClick
