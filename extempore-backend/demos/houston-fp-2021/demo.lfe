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

(set device-name "*midiout*")
(set device-id 2)
(xt.midi:create-out-stream device-name device-id)

;;; Main Sequence

(set midi-channel 2)
(set sequence-name "seq-1")

(set seq1 '(c#3 c#4 c#3 c#4 e3 g#3))
(set seq2 '(c#3 c#4 c#3 c#4 e3 g#3 e4 g#3))
(set seq3 '(e3 e3 e4 g#4 e4 b4 g#4 d#5))
(set seq4 '(e3 d#4 a#5 g4))
(set seq5 '(e3 g#3 c#4 e5))
(set seq6 '(e3 e4 g#4 g#3))
(set pulse1 '(127 127 127 127 127 127))
(set pulse2 '(127 127 127 127 127 127 127 127))
(set pulse3 '(127 127 127 127))

(set beats-per-minute 108)
(set beats-per-measure 6)
(set note-timing "1/2")

(set seq-opts (xt.seq:midi-opts sequence-name
                                device-name
                                device-id
                                midi-channel
                                seq1
                                pulse1
                                beats-per-minute
                                beats-per-measure
                                note-timing))

(defun initial-cutoff () 15)
(xt.midi:cc (mupd seq-opts 'cc-code (cutoff-filter-1) 'cc-value (initial-cutoff)))
(xt.midi:cc-off (mupd seq-opts 'cc-code (resonance-filter-1)))

;; Adjust volume for increase due to effects
(xt.midi:cc (mupd seq-opts 'cc-code (general-volume) 'cc-value 70))

;; Initialize delay effect
(xt.midi:cc (mupd seq-opts 'cc-code (wet-level-delay) 'cc-value 0))
(xt.midi:cc (mupd seq-opts 'cc-code (delay-tempo-sync-midi) 'cc-value 127))
(xt.midi:cc (mupd seq-opts 'cc-code (rate-left-delay) 'cc-value 90))
(xt.midi:cc (mupd seq-opts 'cc-code (rate-right-delay) 'cc-value 108))

;; Initialize chorous effect
(xt.midi:cc (mupd seq-opts 'cc-code (wel-level-chorous) 'cc-value 0))
(xt.midi:cc (mupd seq-opts 'cc-code (chorous-vca-1) 'cc-value 0))

;; Start playing the seqence
(xt.seq:start seq-opts)

;; Add in the chorous
(xt.midi:cc (mupd seq-opts 'cc-code (wel-level-chorous) 'cc-value 65))

;; Add in the delay
(xt.midi:cc (mupd seq-opts 'cc-code (wet-level-delay) 'cc-value 60))



(set noise-opts `#m(scale-func ,#'lutil-math:midi-scale/2))

(loise:add-layer 'cutoff (mset noise-opts 'count 100))
(loise:add-layer 'resonance (mset noise-opts 'count 200))

(set half-cutoff (loise:traverse 'cutoff 'brownian))
(set cutoff (lists:append (lists:reverse half-cutoff) half-cutoff))

(length half-cutoff)
(length cutoff)

(set half-resonance (loise:traverse 'resonance 'brownian))
(set resonance (lists:append (lists:reverse half-resonance) half-resonance))

;; Set cutoff and reso to the first generated values
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (cutoff-filter-1)) (initial-cutoff) (car cutoff) 10)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (resonance-filter-1)) 0 (car resonance) 10)

(defun update-cutoff
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (cutoff-filter-1) 'cc-value head))
   (++ tail (list head))))

(defun loop-cutoff()
  (receive
    ('start
     (io:format "Starting ...~n")
     (erlang:send_after 1000 (self) (update-cutoff cutoff))
     (loop-cutoff))
    ('stop
     (io:format "Stopping ...~n"))
    (cutoff
     (erlang:send_after 1000 (self) (update-cutoff cutoff))
     (loop-cutoff))))

(set loop-cutoff (spawn #'loop-cutoff/0))
(! loop-cutoff 'start)
(! loop-cutoff 'stop)

(defun update-resonance
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (resonance-filter-1) 'cc-value head))
   (++ tail (list head))))

;; Switch to the next sequence
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq2 'pulses pulse2))

(defun loop-tweaks()
  (receive
    ('start
     (io:format "Starting tweaker loop ...~n")
     (erlang:send_after 700 (self) `#(cuto ,(update-cutoff cutoff)))
     (erlang:send_after 500 (self) `#(reso ,(update-resonance resonance)))
     (loop-tweaks))
    ('stop
     (io:format "Stopping tweaker loop ...~n"))
    (`#(cuto ,data)
     (erlang:send_after 700 (self) `#(curo ,(update-cutoff data)))
     (loop-tweaks))
    (`#(reso ,data)
     (erlang:send_after 500 (self) `#(reso ,(update-resonance data)))
     (loop-tweaks))))

(set loop-tweaks (spawn #'loop-tweaks/0))
(! loop-tweaks 'start)
(! loop-tweaks 'stop)

(xt.midi:cc (mupd seq-opts 'cc-code (cutoff-filter-1) 'cc-value (initial-cutoff)))
(xt.midi:cc-off (mupd seq-opts 'cc-code (resonance-filter-1)))

(loise:add-layer 'osc1 (mset noise-opts 'count 300))
(loise:add-layer 'osc2 (mset noise-opts 'count 400))
(loise:add-layer 'osc3 (mset noise-opts 'count 500))
(loise:add-layer 'delay (mset noise-opts 'count 600))
(loise:add-layer 'chorous (mset noise-opts 'count 700))

(set half-osc1 (loise:traverse 'osc1 'brownian))
(set osc1 (lists:append (lists:reverse half-osc1) half-osc1))

(set half-osc2 (loise:traverse 'osc2 'brownian))
(set osc2 (lists:append (lists:reverse half-osc2) half-osc2))

(set half-osc3 (loise:traverse 'osc3 'brownian))
(set osc3 (lists:append (lists:reverse half-osc3) half-osc3))

(set half-delay (loise:traverse 'delay 'brownian))
(set delay (lists:append (lists:reverse half-delay) half-delay))

(set half-chorous (loise:traverse 'chorous 'brownian))
(set chorous (lists:append (lists:reverse half-chorous) half-chorous))

(defun update-osc1
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (gain-mixer-1) 'cc-value head))
   (++ tail (list head))))

(defun update-osc2
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (gain-mixer-2) 'cc-value head))
   (++ tail (list head))))

(defun update-osc3
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (gain-mixer-3) 'cc-value head))
   (++ tail (list head))))

(defun update-delay
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (wet-level-delay) 'cc-value head))
   (++ tail (list head))))

(defun update-chorous
  ((`(,head . ,tail))
   (xt.midi:cc (mupd seq-opts 'cc-code (wel-level-chorous) 'cc-value head))
   (++ tail (list head))))

(defun loop-tweaks()
  (receive
    ('start
     (io:format "Starting tweaker loop ...~n")
     (erlang:send_after 700 (self) `#(cuto ,(update-cutoff cutoff)))
     (erlang:send_after 500 (self) `#(reso ,(update-resonance resonance)))
     (erlang:send_after 1000 (self) `#(osc1 ,(update-osc1 osc1)))
     (erlang:send_after 1500 (self) `#(osc2 ,(update-osc2 osc2)))
     (erlang:send_after 2000 (self) `#(osc3 ,(update-osc3 osc3)))
     (erlang:send_after 2500 (self) `#(delay ,(update-delay delay)))
     (erlang:send_after 3000 (self) `#(chorous ,(update-chorous chorous)))
     (loop-tweaks))
    ('stop
     (io:format "Stopping tweaker loop ...~n"))
    (`#(cuto ,data)
     (erlang:send_after 700 (self) `#(curo ,(update-cutoff data)))
     (loop-tweaks))
    (`#(reso ,data)
     (erlang:send_after 500 (self) `#(reso ,(update-resonance data)))
     (loop-tweaks))
    (`#(osc1 ,data)
     (erlang:send_after 1000 (self) `#(osc1 ,(update-osc1 data)))
     (loop-tweaks))
    (`#(osc2 ,data)
     (erlang:send_after 1500 (self) `#(osc2 ,(update-osc2 data)))
     (loop-tweaks))
    (`#(osc3 ,data)
     (erlang:send_after 2000 (self) `#(osc3 ,(update-osc3 data)))
     (loop-tweaks))
    (`#(delay ,data)
     (erlang:send_after 2500 (self) `#(delay ,(update-delay data)))
     (loop-tweaks))
    (`#(chorous ,data)
     (erlang:send_after 2500 (self) `#(chorous ,(update-chorous data)))
     (loop-tweaks))))

;; Set cutoff and reso to the first generated values
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (cutoff-filter-1)) (initial-cutoff) (car cutoff) 10)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (resonance-filter-1)) 0 (car resonance) 10)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (gain-mixer-1)) 40 (car osc1) 15)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (gain-mixer-2)) 40 (car osc3) 15)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (gain-mixer-3)) 40 (car osc3) 15)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (wet-level-delay)) 0 (car delay) 15)
(xt.midi:cc-ramp (mupd seq-opts 'cc-code (wel-level-chorous)) 0 (car chorous) 15)

(set loop-tweaks (spawn #'loop-tweaks/0))
(! loop-tweaks 'start)
(! loop-tweaks 'stop)

;; Switch to the next sequence
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq3 'pulses pulse2))
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq4 'pulses pulse3))
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq5 'pulses pulse3))
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq6 'pulses pulse3))
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq2 'pulses pulse2))
(xt.seq:set-midi-notes! (mupd seq-opts 'notes seq1 'pulses pulse1))

(! loop-tweaks 'stop)

(xt.seq:stop seq-opts)

