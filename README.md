# Atom Pane Browser

An Atom browser like a web browser

![Atom Pane Browser](https://raw.github.com/nju33/atom-pane-browser/master/screenshot.png)

## Motivation

want to reduce window switching during development!

## Install

```
apm install pane-browser
```

## Keymaps

```
'ctrl-alt-b': 'Pane Browser: Open'
'ctrl-alt-c': 'Pane Browser: Open from clipboard'
```

## Commands

- `Pane Browser: Open`  
  Open the PaneBrowser to the right pane
- `Pane Browser: Open from clipboard`  
  Open search results with clipboard contents
- `Pane Browser: Reset all state`  
  Delete all holding state

## Options

- `minify zoom level`, default: `0.7`  
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
