# Lisp NYC - 11 May 2021

*Erlang Music Systems Programming with Lisp*

## Preparation

### Installing Extempore

1. Visit https://github.com/digego/extempore/releases/tag/v0.8.8
1. Select the tarball for your platform
1. Download and unpack it
1. Copy the contents to a location of your choice

To that last point, my latest version of Extempore is saved to
`/opt/extempore/0.8.8`.

### Setting up an Editor

Supported editors for interacting with the Extempore server are

* Emacs
* VS Code

Instructions for setting up your editor of preference are here:

* https://extemporelang.github.io/docs/guides/editor-support/

In Emacs:

* Connect to the server: `M-x` -> `extempore-connect`
* Execute code: `C-c C-c`

### Downloading the Demo

In a terminal:

``` shell
git clone https://github.com/ut-proj/music.git ut-music
```

Then open that up in Emacs or VS Code.

### Starting Extempore

Suggested options:

``` shell
cd /opt/extempore/0.8.8
./extempore \
  --sharedir=/opt/extempore/0.8.8 \
  --port=7099 \
  --samplerate=48000 \
  --frames=64
```

To help keep the timings consistent, especially when creating
music with sequences, a la Berlin School, you'll want to reduce
the framerate. I've found 64 is a great default for this which
keeps all the sequences playing nicely in time.

