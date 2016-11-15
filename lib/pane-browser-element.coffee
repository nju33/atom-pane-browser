class PaneBrowserElement extends HTMLElement
  constructor: ->
    @element = document.registerElement 'atom-pane-browser', @

instance = false

module.exports = do ->
  if instance
    instance.element
  else
    instance = new PaneBrowserElement()
    instance.element
