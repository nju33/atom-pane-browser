<h1><img src="https://github.com/nju33/atom-pane-browser/blob/master/images/icon_32x32@2x.png?raw=true" width="30">&nbsp;Pane Browser</h1>

🗿 An browser on Atom

![Atom Pane Browser](https://raw.github.com/nju33/atom-pane-browser/master/screenshot.png)

## Motivation

want to reduce window switching during development!

## Install

```
apm install pane-browser
```

## Keymaps

```cson
'ctrl-alt-b': 'Pane Browser: Open'
'ctrl-alt-c': 'Pane Browser: Open from clipboard'

# mac
'.platform-darwin atom-pane atom-pane-browser':
    'cmd-r': 'Pane Browser: Reload'
    'cmd-alt-i': 'Pane Browser: Open devtool'
# windows
'.platform-windows atom-pane atom-pane-browser':
    'ctrl-r': 'Pane Browser: Reload'
    'ctrl-alt-i': 'Pane Browser: Open devtool'
```

## Commands

- `Pane Browser: Open`  
  Open the PaneBrowser to the right pane
- `Pane Browser: Open from clipboard`  
  Open search results with clipboard contents
- `Pane Browser: Reset all state`  
  Delete all holding state
- `Pane Browser: Reload`
  Reload the current page on current browser
- `Pane Browser: Open devtool`
  Open devtool on current browser
- `Pane Browser: Capture`  
  Capture page on current browser
- `Pane Browser: Capture @2x`  
  Capture page (width x2, height x2) on current browser
- `Pane Browser: Capture @3x`  
  Capture page (width x3, height x3) on current browser

## Scheme

- `gh|github`
  For example, `gh://nju33/atom-pane-browser` will be `https://github.com/nju33/atom-pane-browser`

## Options

- `defaultScale` [default: `1.0`]  
  Scale size in the state without doing anything.  
  (In other words, the `transform: scale (n)` of `<webview/>`)
- `minifyZoomLevel`, [default: `0.7`]  
  When the menu button is clicked, the page reduction ratio applied
- `user agent`, default: `Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1`  
  When the menu button is clicked, the applied user agent

## Interpretation of URL

- Begin with `https`  
  Access as it is
- Only 4 digits or more (e.g. `3000` `4567` `8888` `33333`)  
  Interpreted as port number, accessed by localhost (e.g `localhost:3000`)
- When `.` and `:` are included  
  Interpret as url and access (e.g. `example.com` `localhost:3000`)
- other  
  Google search
