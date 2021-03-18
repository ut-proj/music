# Glasgow CodeCraft - 19 March 2021

*Generative Music Programming with Duncan McGreggor*

## Preparation

### Installing Extempore

1. Visit https://github.com/digego/extempore/releases/tag/v0.8.8
1. Select the tarball for your platform
1. Download and unpack it
1. Copy the contents to a location of your choice

To that last point, my latest version of Extempore is saved to
`/opt/extempore/8.8.0`.

### Setting up an Editor

Supported editors for interacting with the Extempore server are

* Emacs
* VS Code

Instructions for setting up your editor of preference are here:

* https://extemporelang.github.io/docs/guides/editor-support/

### Downloading the Demo

In a terminal:

``` shell
git clone https://github.com/ut-proj/music.git ut-music
```

Then open that up in Emacs or VS Code.

### Starting Extempore

Suggested options:

``` shell
cd /opt/extempore/8.8.0
./extempore \
  --sharedir=/opt/extempore/8.8.0 \
  --port=7099 \
  --samplerate=48000 \
  --frames=64
```

To help keeping the timings consistent, especially when creating
music with sequences, a la Berlin School, you'll want to reduce
the framerate. I've found 64 is a great default for this which
keeps all the sequences playing nicely in time.


## Proposed Talking Points

* What is undertone and why was it created?
* Examples:
  * Ambient/space music
  * Early Berlin School electronica
  * Piano pieces
* Why create it with a language from the Erlang ecossytem?
  * Quick review of the archtiecture
  * Code samples of LFE/OTP
* Sound synthesis as programming
* Programming for sound synthesis
* Interactive Session:
  * undertone backends
  * exploring the Extempore backend
