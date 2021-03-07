# Speaker Notes

## Intro

Let's explore how to arrive at a finished piece like that from a collection of rather odd chords.

While undertone and Extempore are starting up, here are the simplified chords for our starting tune,
LFE's unofficial theme song, and here's some brief analysis of the modes ... and durations.

Okay, undertone is ready to go. let's load up our files ...

And set up the MIDI output ...

Paste the code for our Markov chains for the starting chord transitions and the initial volume.

## 1st Step

Here we've defined a very simply chord-builder that merely wraps Extempore's own chord-building
function.

Here's our starting `progression` function, the foundation of our piece. It's responsible for
playing notes and getting the inputs for the next iteration: this includes getting the next
chord to use, the next duration of play, and how loudly it should be played.

Let's start the progression.

## 2nd Step

This is very plain: simple chords and transitions from one to the other, with no dynamics.

Let's change that by updating our `volume transitions` and adding another chain for situations
where we want to have the possibility for more dramatic shifts in volume between notes.

To take advantage of this, we'll have to override our default `play-note` function that we've
saved to our `funs.xtm` file and have it use a different Markov chain.

We can also make life more interesting for our chords, namely by radomly changing how many notes
are being played in a given chord.

We haven't changed what the `progression` function does, so we don't need to update it with a
new definition.

## 3rd Step

We can make things even more interesting for our bass notes by conditionally arpeggiating the
notes of our chords.

This function keeps track of the duration of each note played in the arpeggio amd will bail if
the total of those durations exceeds the time aloted for the given chord.

We do need to update the `progression` function for this.

And we can add some more spice by randomly adding syncopation to our arpeggio -- delaying the moment
the first note plays.

## 4th Step

Now it's time to pull the right hand into the mix. We'll start with a sinple melody function that
will either create a chord -- just like we did for the left hand -- or select a set of notes
we took from the original piece.

We'll create a new function for playing the ramonly selected notes for a melody: whatever notes
get selected with the `build-melody` function will either be played randomly, one at a time
(until the time is up for the given chord) or will play no note at all, intead inserting a rest.

We need to update our progression function to support playing melodies now ...

And you can hear it kick in right there.

## 5th Step

Let's make our melody-builder more interesting: this function create melodies with different
numbers of notes it will iterate through, and a different high and low range that will be used
for however long the current chord is played.

We need to update our melody-player to use this ...

Perhaps that's a bit busy now, so let's simplify the note timings to play a little longer

## 6th Step

Now we're approaching the end of our piece, so let's soften the volumes.

This is also a good time to demonstrate how to depress and lift the sustain pedal. We'll add another
Markov chain for transitions where pedal release should occur.

Then in out `progression` function we'll send MIDI change control messages for the pedal.

And here's where we check the sustain Markov chain pedeal release ...

## 7th Step

Let's up the dissonance for a modern classical feel. Here we'll take some notes from the rather odd
set notes that follow each other in the original piece. And we'll update the `play-melody` function
to randomly use these as the basis for the next bit of the melody, instead of what we have been
using so far.

## 8th Step

Finally, we'll drop our volume even more and reduce the total set of chords possible for our
transitions.

Next we'll update the left hand to go back to simply playing chords -- no arpeggios. 

We'll slow things down some more ...

Reduce the total chords to just one ...

And then have it play one last chord which doesn't have a legal transition, effectively finishing
our piece after it plays.
