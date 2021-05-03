# Glasgow CodeCraft - 19 March 2021

*Generative Music Programming with Duncan McGreggor*

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


## Proposed Talking Points

* Introduction
  * http://undertone.lfe.io/presentations/lambda-days-2021/#/2
  * http://undertone.lfe.io/presentations/lambda-days-2021/#/3
* What is undertone and why was it created?
* Examples:
  * Ambient/space music:
     * https://soundcloud.com/forgotten-tones/conivnctio-iovis-et-satvrni
  * Early Berlin School electronica
     * Using LFE's wrapper for sequencing in Extempore: https://www.youtube.com/watch?v=DI3UcPAdayo
     * Markov chains and multiple tracks of synth: https://www.youtube.com/watch?v=-mTUNt3N5AU
     * More interesting sequences: https://www.youtube.com/watch?v=k2OB-bpHYDg
  * Piano pieces
     * "Patterns of Improbability" - https://soundcloud.com/oubiwann/journey-of-the-source-variation-3
     * "Debussy's Spiral Arm" - https://soundcloud.com/oubiwann/debussys-spiral-arm
     * Variation on HHGG theme: https://www.youtube.com/watch?v=neSGoz2F1d8
* Why create it with a language from the Erlang ecossytem?
  * Quick review of the archtiecture
    * README: https://github.com/ut-proj/undertone
    * Maybe some OmniGraffle
  * Code samples of LFE/OTP
    * Load up app and sup in Emacs
    * Look at the REPL definition
* Sound synthesis as programming
  * Maybe some slides: http://undertone.lfe.io/presentations/lambda-days-2021/#/39
* Programming for sound synthesis
  * What Extempore accomplishes
  * How undertone augments this with LFE
     * Both as a language
     * And as a means of unifying / orchestrating multiple services / processes
* Interactive Session:
  * undertone backends (SC, Extempore, "Bevin")
  * exploring the Extempore backend
  * watch Andrew Sorensen's brilliant original: https://www.youtube.com/watch?v=xpSYWd_aIiI
