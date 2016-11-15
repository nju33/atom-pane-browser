describe "Pane Browser", ->
  beforeEach ->
    atom.workspace.open()

  it "Open", ->
    ws = atom.views.getView atom.workspace
    expect(ws.querySelector('atom-pane-browser__box')).toBe(null)

    setTimeout ->
      atom.commands.dispatch(ws, 'Pane Browser: Open')
      expect(ws.querySelector('atom-pane-browser__box')).not.toBe(null)
    , 0

  it "Open from clipboard", ->
    ws = atom.views.getView atom.workspace
    atom.clipboard.write 'https://www.npmjs.com/'

    setTimeout ->
      atom.commands.dispatch(ws, 'Pane Browser: Open from clipboard')
      expect(ws.querySelector('atom-pane-browser__box')).not.toBe(null)
      expect(ws.querySelector('.tom-pane-browser__omni').value).toBe('https://www.npmjs.com/')
    , 0
