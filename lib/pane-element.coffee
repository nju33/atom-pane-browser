paneBrowser = require './pane-browser-element'

module.exports = class PaneElement
  constructor: ({path, textEditor, clipboard}) ->
    @textEditor = textEditor
    @clipboard = clipboard

    @state = do =>
      text = @textEditor.getText()
      try
        JSON.parse text
      catch err
        path: path
        url: 'https://www.google.com/'
        ua: false

    @config =
      minifyZoomLevel: atom.config.get 'pane-browser.minifyZoomLevel'
      ua: atom.config.get 'pane-browser.ua'

    atom.config.onDidChange 'pane-browser.minifyZoomLevel', (val) =>
      @config.minifyZoomLevel = val
    atom.config.onDidChange 'pane-browser.ua', (val) =>
      @config.ua = val

  create: () ->
    element = @createRoot [
      @createMenu [
        @createBackBtn()
        @createForwardBtn()
        @createReloadBtn()
        @createOmni()
        @createGlassBtn()
        @createUABtn()
        @createDevtoolBtn()
      ]
      @createWebview()
    ]

    removeEventListeners = @eventListener()
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
    @back.setAttribute 'title', 'Go back'
    @back

  createForwardBtn: ->
    @forward = document.createElement 'div'
    @forward.className = 'atom-pane-browser__forward-btn atom-pane-browser__btn--disabled'
    @forward.setAttribute 'title', 'Go forward'
    @forward

  createReloadBtn: ->
    @reload = document.createElement 'div'
    @reload.className = 'atom-pane-browser__reload-btn'
    @reload.setAttribute 'title', 'Reload this pane'
    @reload

  createOmni: ->
    @omni = document.createElement 'input'
    @omni.className = 'atom-pane-browser__omni native-key-bindings'
    @omni

  createGlassBtn: ->
    @glass = document.createElement 'div'
    @glass.innerHTML = '<span class="atom-pane-browser__glass-inner"></span>'
    @glass.className = 'atom-pane-browser__glass--minify'
    @glass.setAttribute 'title', 'Minify zoom'
    @glass

  createUABtn: ->
    @ua = document.createElement 'div'
    @ua.className = 'atom-pane-browser__ua--sp'
    @ua.setAttribute 'title', 'Set user-agent'
    @ua

  createDevtoolBtn: ->
    @devtool = document.createElement 'div'
    @devtool.className = 'atom-pane-browser__devtool-btn'
    @devtool.setAttribute 'title', 'Open the devtool'
    @devtool

  createWebview: () ->
    @webview = document.createElement('webview');
    @webview.className = 'atom-pane-browser__webview native-key-bindings'
    @webview.style.visibility = 'hidden'
    @webview.src = (@clipboard && @getClipboardTextAndAdjust clipboard) ||
                   @state.url
    @webview.style.height = 'calc(100% - 38px)'

    @webview

  getClipboardTextAndAdjust: ->
    false unless @clipboard

    text = atom.clipboard.read()
    @adjustOmniText text

  adjustOmniText: (text) ->
    if /https?:\/\//.test text
      text
    else if /^\d{4,}/.test text
      number = text.match(/(^\d{4,})/)[1]
      "http://localhost:#{number}"
    else if /[^.]+(?:\.[^.]|:\d{4})/.test text
      "http://#{text}"
    else
      "https://www.google.com/search?q=#{text}"

  eventListener: ->
    removeEventListeners = []

    handleDomReady = do =>
      init = false
      =>
        url = @webview.getURL()
        if /http:\/\//.test url
          url = url.replace /http:\/\//, ''
        @omni.value = url
        @state.url = url
        @saveState()

        if @webview.canGoBack()
          @back.className = 'atom-pane-browser__back-btn'
        else
          @back.className = 'atom-pane-browser__back-btn atom-pane-browser__btn--disabled'

        if @webview.canGoForward()
          @forward.className = 'atom-pane-browser__forward-btn'
        else
          @forward.className = 'atom-pane-browser__forward-btn atom-pane-browser__btn--disabled'

        if not init and @state.ua
          @webview.setUserAgent @config.ua
          @webview.reload()
          @ua.className = 'atom-pane-browser__ua--lt'
          @ua.setAttribute 'title', 'Reset user-agent'

        unless init
          @webview.style.visibility = 'visible'
          init = true

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
        @webview.setZoomFactor @config.minifyZoomLevel
        @glass.className = 'atom-pane-browser__glass--magnify'
        @glass.setAttribute 'title', 'Magnify zoom'
      else
        @webview.setZoomFactor 1
        @glass.className = 'atom-pane-browser__glass--minify'
        @glass.setAttribute 'title', 'Minify zoom'
    @glass.addEventListener 'click', handleGlass
    removeEventListeners.push @glass.removeEventListener.bind @glass, 'click', handleGlass

    handleUA = do =>
      handler = (e) =>
        if @ua.classList.contains 'atom-pane-browser__ua--sp'
          @state.ua = true
          @webview.setUserAgent @config.ua
          @webview.reload()
          @ua.className = 'atom-pane-browser__ua--lt'
          @ua.setAttribute 'title', 'Reset user-agent'
        else
          @state.ua = false
          @webview.setUserAgent ''
          @webview.reload()
          @ua.className = 'atom-pane-browser__ua--sp'
          @ua.setAttribute 'title', 'Set user-agent'
        @saveState()

      handler.bind @
    @ua.addEventListener 'click', handleUA
    removeEventListeners.push @ua.removeEventListener.bind @ua, 'click', handleUA

    handleDevtoolClick = (e) => @webview.openDevTools()
    @devtool.addEventListener 'click', handleDevtoolClick
    removeEventListeners.push @devtool.removeEventListener.bind @devtool, 'click', handleDevtoolClick

  saveState: ->
    @textEditor.deleteLine()
    try
      @textEditor.setText JSON.stringify @state
      @textEditor.save()
