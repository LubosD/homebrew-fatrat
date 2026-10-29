# Homebrew tap for FatRat

[FatRat](https://github.com/LubosD/fatrat) is a download manager with BitTorrent,
HTTP(S) and FTP support, a web interface and Python extensions.

## Install

There is no macOS-compatible release yet, so install from the latest source:

```sh
brew install --HEAD lubosd/fatrat/fatrat
```

Upgrade to the newest commit with `brew upgrade --fetch-HEAD fatrat`.

FatRat is built as `FatRat.app`. To launch it from Finder, Launchpad or Spotlight,
symlink it into `/Applications`:

```sh
ln -sf "$(brew --prefix)/opt/fatrat/FatRat.app" /Applications/FatRat.app
```

The symlink points at Homebrew's `opt` path, so it keeps working across upgrades.
`fatrat` is also on your `PATH` for terminal use (e.g. `fatrat --nogui`).

The formula builds the Qt desktop UI, BitTorrent (libtorrent-rasterbar),
curl-based HTTP/FTP, the web interface and Python extensions (Python 3.15).
D-Bus is disabled on macOS.
