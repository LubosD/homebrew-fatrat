# Homebrew tap for FatRat

[FatRat](https://github.com/LubosD/fatrat) is a download manager with BitTorrent,
HTTP(S) and FTP support, a web interface and Python extensions.

## Install

There is no macOS-compatible release yet, so install from the latest source:

```sh
brew install --HEAD lubosd/fatrat/fatrat
```

Upgrade to the newest commit with `brew upgrade --fetch-HEAD fatrat`.

The formula builds the Qt desktop UI, BitTorrent (libtorrent-rasterbar),
curl-based HTTP/FTP, the web interface and Python extensions (Python 3.15).
D-Bus is disabled on macOS.
