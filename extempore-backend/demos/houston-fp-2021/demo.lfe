;;;; An undertone / Extempore / LFE demonstration of a new feature in undertone
;;;; that uses noise grids to control MIDI devices.
;;;;
;;;; Synthesizer: Arturia modular V (Moog System 55 emulator)
;;;; Main Bank Selection: Gentle Gee (custom)
;;;; Background Selections:
;;;; * In the Space (w/custom shimmer)
;;;; * Air Pno2 (tweaked for higher ressonance)
;;;;
;;;; LFE usage expects that the following are executed in the undertone
;;;; directory:
;;;; * git clone git@github.com:ut-proj/undertone.git
;;;; * rebar3 compile
;;;; * rebar3 lfe repl
;;;;
(include-lib "include/notes/midi-name.lfe")
(include-lib "include/arturia/modular-v/midi-gentle-gee.lfe")

(xt.midi:init)

(xt.midi:list-devices)

;; Set up general MIDI
(progn
  (set device-name "*midiout*")
  (set device-id 2)
  (xt.midi:create-out-stream device-name device-id))

;;; Main Sequence

;; Set up sequence-specific MIDI and timing
(progn
  (set midi-channel 2)
  (set sequence-name "seq-1")
  (set beats-per-minute 108)
  (set beats-per-measure 6)
  (set note-timing "1/2")
  'ok)

;; Define the notes and pulses we'll use as well as the options
(progn
  (set seq1 '(c#3 c#4 c#3 c#4 e3 g#3))
  (set seq2 '(c#3 c#4 c#3 c#4 e3 g#3 e4 g#3))
  (set seq3 '(e3 e3 e4 g#4 e4 b4 g#4 d#5))
  (set seq4 '(e3 d#4 a#5 g4))
  (set seq5 '(e3 g#3 c#4 e5))
  (set seq6 '(e3 e4 g#4 g#3))
  (set pulse1 '(127 127 127 127 127 127))
  (set pulse2 '(127 127 127 127 127 127 127 127))
  (set pulse3 '(127 127 127 127))
  ;; Create options for use by the MIDI functions we'll be calling
  (set seq-opts (xt.seq:midi-opts sequence-name
                                  device-name
                                  device-id
                                  midi-channel
                                  seq1
                                  pulse1
                                  beats-per-minute
                                  beats-per-measure
                                  note-timing))
  'ok)

;; Set up some default values
(progn
  (set on 127)
  (set off 0)
  (set initial-volume 70)
  (set initial-cutoff 7)
  'ok)

;; Define some convenience functions
(defun cc (knob val)
  (xt.midi:cc (mupd seq-opts 'cc-code knob 'cc-value val)))

(defun ramp (knob init-val final-val ramp-time)
  (xt.midi:cc-ramp
   (mupd seq-opts 'cc-code knob) init-val final-val ramp-time))

(defun update-knob
  ((knob `(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code knob 'cc-value head))
   (++ tail (list head))))

(defun change-seq (notes pulses)
  (xt.seq:set-midi-notes! (mupd seq-opts 'notes notes 'pulses pulses)))

(defun initialise-knobs ()
  ;; The basics
  (cc (general-volume) initial-volume)
  (cc (cutoff-filter-1) initial-cutoff)
  (cc (resonance-filter-1) off)
  ;; The delay effect
  (cc (wet-level-delay) off)
  (cc (delay-tempo-sync-midi) on)
  (cc (rate-left-delay) 90)
  (cc (rate-right-delay) 108)
  ;; the chorous effect
  (cc (wet-level-chorous) off)
  (cc (chorous-vca-1) off))

(defun schedule-knob (prefix ms pid knob data)
  (erlang:send_after ms pid `(,prefix ,ms ,pid ,knob ,(update-knob knob data))))

(defun random-walk (layer-name)
  (let ((half (loise:traverse layer-name 'brownian)))
    (++ (lists:reverse half half))))

;; Start playing the seqence
(xt.seq:start seq-opts)

;; Create the noise layers we'll be using
(progn
  (set noise-opts `#m(scale-func ,#'lutil-math:midi-scale/2))
  (loise:add-layer 'cutoff (mset noise-opts 'count 100))
  (loise:add-layer 'resonance (mset noise-opts 'count 200 'multiplier 2))
  (loise:add-layer 'osc3 (mset noise-opts 'count 500 'multiplier 1))
  (loise:add-layer 'delay (mset noise-opts 'count 600 'multiplier 2)))

;; Create random noise-walks fpr each
(progn
  (set cutoff (random-walk 'cutoff))
  (set resonance (random-walk 'resonance))
  (set osc3 (random-walk 'osc3))
  (set delay (random-walk 'delay))
  'ok)

;; Set cutoff to the first generated values
(ramp (cutoff-filter-1) initial-cutoff (car cutoff) 10)

;; Let's define a loop function that can receive messages and
;; update a knob
(defun loop-cutoff()
  (receive
    ('start
     (io:format "Starting ...~n")
     (schedule-knob 'cutoff 500 (self) (cutoff-filter-1) cutoff)
     (loop-cutoff))
    ('stop
     (io:format "Stopping ...~n"))
    (args 
     (apply #'schedule-knob/5 args)
     (loop-cutoff))))

;; Create a server and tell it to start
(set loop-cutoff (spawn #'loop-cutoff/0))
(! loop-cutoff 'start)

;; Experiment done, let's stop it
(! loop-cutoff 'stop)

;; Switch to the next sequence
(change-seq seq2 pulse2)

;; Set cutoff and reso to the first generated values
(progn
  (ramp (cutoff-filter-1) initial-cutoff (car cutoff) 10)
  (ramp (resonance-filter-1) off (car resonance) 10))

;; What does it look like when we want to control more than one knob?
(defun loop-knob-tweaks()
  (receive
    ('start
     (io:format "Starting tweaker loop ...~n")
     (schedule-knob 'cutoff 500 (self) (cutoff-filter-1) cutoff)
     (schedule-knob 'reso 1000 (self) (resonance-filter-1) resonance)
     (loop-knob-tweaks))
    ('stop
     (io:format "Stopping tweaker loop ...~n"))
    (args 
     (apply #'schedule-knob/5 args)
     (loop-knob-tweaks))))

;; Start the mini-server
(set loop-knob-tweaks (spawn #'loop-knob-tweaks/0))
(! loop-knob-tweaks 'start)

;; Bump the volume
(ramp (general-volume) initial-volume 110 5)

;; Now we know what we need to do, let's stop it and
;; reset the knobs
(! loop-knob-tweaks 'stop)

;; Now let's go big
(defun loop-knob-tweaks()
  (receive
    ('start
     (io:format "Starting tweaker loop ...~n")
     (schedule-knob 'cutoff 500 (self) (cutoff-filter-1) cutoff)
     (schedule-knob 'reso 1000 (self) (resonance-filter-1) resonance)
     (schedule-knob 'osc3 500 (self) (gain-mixer-3) osc3)
     (schedule-knob 'delay 1000 (self) (wet-level-delay) delay)
     (loop-knob-tweaks))
    ('stop
     (io:format "Stopping tweaker loop ...~n"))
    (args 
     (apply #'schedule-knob/5 args)
     (loop-knob-tweaks))))

;; Set all knobs to the first generated values
(progn
  (ramp (cutoff-filter-1) initial-cutoff (car cutoff) 5)
  (ramp (resonance-filter-1) off (car resonance) 5)
  (ramp (gain-mixer-3) 70 (car osc3) 10)
  (ramp (wet-level-delay) 0 (car delay) 10))

(set loop-knob-tweaks (spawn #'loop-knob-tweaks/0))
(! loop-knob-tweaks 'start)

;; Switch to the next sequence
(defun do-changes()
  (change-seq seq3 pulse2)
  (timer:sleep (trunc (* 3.7 1000 2.5)))
  (change-seq seq4 pulse3)
  (timer:sleep (trunc (* 3.7 1000 0.5)))
  (change-seq seq5 pulse3)
  (timer:sleep (trunc (* 3.7 1000 0.5)))
  (change-seq seq6 pulse3)
  (timer:sleep (trunc (* 3.7 1000 1)))
  (change-seq seq2 pulse2)
  (timer:sleep (trunc (* 3.7 1000 2.5)))
  (change-seq seq1 pulse1))

(do-changes)

(! loop-knob-tweaks 'stop)

(xt.seq:stop seq-opts)

;; Extra: here's how to generate image representations of the data that was
;;        used for the noise layers
(loise:image "cutoff.png" #m(count 100 width 1600 height 1600))
(loise:image "resonance.png" #m(count 200 multiplier 2 width 1600 height 1600))
(loise:image "osc3.png" #m(count 500 multiplier 1 width 1600 height 1600))
(loise:image "delay.png" #m(count 600 multiplier 2 width 1600 height 1600))
