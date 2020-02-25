![orca_norns|690x231,100%](https://llllllll.co/uploads/default/original/3X/e/e/ee7a2a1460ac4c0a54c8a0b067b7e7d9c35f23fd.png)

## [Orca](https://100r.co/pages/orca.html) is a visual programming language, designed to create procedural sequencers on the fly.

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-orca-empty.png)


---

### Requirements	

Orca supports 3 different engines, but in order for them to work they must be installed.

- [FM7 engine](https://llllllll.co/t/fm7-norns/)
- [Passersby engine](https://llllllll.co/t/passersby/)
- [PolyPerc engine](https://llllllll.co/t/awake/)



### Documentation

Please refer to original [docs](https://github.com/hundredrabbits/Orca#operators)


---

## Operators

- `A` **add**(*a* b): Outputs sum of inputs.
- `B` **bounce**(*rate* mod): Outputs values between inputs.
- `C` **clock**(*rate* mod): Outputs modulo of frame.
- `D` **delay**(*rate* mod): Bangs on modulo of frame.
- `E` **east**: Moves eastward, or bangs.
- `F` **if**(*a* b): Bangs if inputs are equal.
- `G` **generator**(*x* *y* *len*): Writes operands with offset.
- `H` **halt**: Halts southward operand.
- `I` **increment**(*step* mod): Increments southward operand.
- `J` **jumper**(*val*): Outputs northward operand.
- `K` **konkat**(*len*): Reads multiple variables.
- `L` **loop**(*step* *len* val): Moves eastward operands.
- `M` **multiply**(*a* b): Outputs product of inputs.
- `N` **north**: Moves Northward, or bangs.
- `O` **read**(*x* *y* read): Reads operand with offset.
- `P` **push**(*len* *key* val): Writes eastward operand.
- `Q` **query**(*x* *y* *len*): Reads operands with offset.
- `R` **random**(*min* max): Outputs random value.
- `S` **south**: Moves southward, or bangs.
- `T` **track**(*key* *len* val): Reads eastward operand.
- `U` **uclid**(*step* max): Bangs on Euclidean rhythm.
- `V` **variable**(*write* read): Reads and writes variable.
- `W` **west**: Moves westward, or bangs.
- `X` **write**(*x* *y* val): Writes operand with offset.
- `Y` **jymper**(*val*): Outputs westward operand.
- `Z` **lerp**(*rate* target): Transitions operand to input.
- `*` **bang**: Bangs neighboring operands.
- `#` **comment**: Halts a line.

## IO / Norns operators

- `/` **softcut**(*playhead* *rec* *play* level rate position)
- `\` **softcut param**(*playhead* *param* value): Sets softcut param on bang
- `>` **g.write**(*x* *y* value): Sets grid led on bang.
- `<` **g.read**(*x* *y*): Reads specific coordinates. If value > 6 outputs bang.
- `:` **midi**(*channel* octave note velocity length): Sends a MIDI note.
- `|` **synth**(*octave* *note*): Plays a note with the synth engine.
- `-` **synth param**(*param* *value*): Sets synth param on bang.
- `%` **mono**(*channel* octave note velocity length): Sends monophonic MIDI note.
- `&` **midi in**(*channel*): Outputs midi note
- `^` **cc in**(*cc*): Outputs midi cc value
- `!` **cc**(*channel* knob value): Sends MIDI control change.
- `=` **OSC** (*path*;x;y..): Locks each consecutive eastwardly ports. `;` is delimeter for values
- `$` **r.note**(scale-mode note): Outputs random note within scale.
- `?` **levels**(*param* value): Sets selected volume level on bang



### SYNTH

The **SYNTH** operator `|` inputs vary based on selected engine, but (*octave*, *note* ...) are always required (along with a bang) to produce sound.

There are 3 different engine supported by Orca [FM7](https://llllllll.co/t/fm7-norns/), [Passersby](https://llllllll.co/t/passersby/), and [PolyPerc](https://llllllll.co/t/awake/) (integration of [Timber](https://llllllll.co/t/timber/) and [R](https://github.com/antonhornquist/r) are on the roadmap). Within the params menu engines can be changed.

- **FM7** is a "Polyphonic Synthesizer for Norns With 6 Operator Frequency Modulation". When this engine is selected, the **SYNTH** operator `|` takes up to 4 different inputs (*octave*, *note*, voice, amp). For example `|4C..` will play a C at the 4th octave (Midi scale).
- **PASSERSBY** is a "West Coast style mono synth". When this engine is selected, the **SYNTH** operator `|` takes up to 6 different inputs (*octave*, *note*, velocity, timbre, pitchBend, pressure). For example `|4Cz...` will play a C at the 4th octave (Midi scale) with a velocity of 255.
- **POLYPERC** is a "simple polyphonic filtered decaying square wave". When this engine is selected, the **SYNTH** operaptor `|` takes up to 2 inputs (*octave*, *note*). For example `|4C` will play a C at the 4th octave (Midi scale).



### SYNTH PARAMS

Each synth engine has numerous settings to modulate its sound profile. The **SYNTH PARAMS** operator `-` are (*param* *value*) (except for `FM7` see below) these 2 params are always required (along with a bang) to modulate a given parameter. 


**FM7**
When this engine is selected the **SYNTH PARAMS** operator `-` takes up to 3 inputs (*param* *value* *voice*). This particular engine allows for a complex combination of params. For example `-5i1` sets the "Osc(illator) Amp(litude) Env(elope) Attack" to `5.14` seconds for voice `1`.  Load the included to `fm7-demo.orca` demo to see more params (be sure to select `FM7` within the params menu first).

- `1`: Osc Frequency Multiplier (Hz)
- `2`: Osc Phase (radians)
- `3`: Osc Amplitude (decibels)
- `4`: Carrier Amplitude (decibels)
- `5`: Osc Amp Env Attack (seconds)
- `6`: Osc Amp Env Decay (seconds)
- `7`: Osc Amp Env Sustain (decibels)
- `8`: Osc Amp Env Release (seconds)
- `9`: Osc1 Phase Mod Osc (decibels)
- `a`: Osc2 Phase Mod Osc (decibels)
- `b`: Osc3 Phase Mod Osc (decibels)
- `c`: Osc4 Phase Mod Osc (decibels)
- `d`: Osc5 Phase Mod Osc (decibels)
- `e`: Osc6 Phase Mod Osc (decibels)


**Passersby**
When this engine is selected the **SYNTH PARAMS** operator `-` takes up to 2 inputs (*param* *value*). For example `-51` sets the "Envelope Type " to `"LPG"`. Load the included to `passersby-demo.orca` demo to see more params (be sure to select `Passersby` within the params menu first).

- `1`: Amp
- `2`: Attack (seconds)
- `3`: Decay (seconds)
- `4`: Drift
- `5`: Envelope Type 
  - values `1`: LPG, `2`: Sustain
- `6`: FM Low Amount
- `7`: FM Low Ratio
- `8`: FM High Amount
- `9`: FM High Ratio
- `a`: Glide (seconds)
- `b`: LFO Frequency (Hz)
- `c`: LFO Shape
  - values `1`: Triangle, `2`: Ramp, `3`: Square, `4`: Random
- `d`: LFO > Attack
- `e`: LFO > Decay
- `f`: LFO > FM Low
- `g`: LFO > FM High
- `h`: LFO > Frequency (Hz)
- `i`: LFO > Peak
- `j`: LFO > Reverb Mix
- `k`: LFO > Wave Folds
- `l`: LFO > Wave Shape
- `m`: Peak (Hz)
- `n`: Pitch Bend All
- `o`: Pressure All
- `p`: Reverb Mix
- `q`: Timbre All
- `r`: Wave Folds
- `s`: Wave Shape


**PolyPerc**
When this engine is selected the **SYNTH PARAMS** operator `-` takes up to 2 inputs (*param* *value*). For example `-3z` sets the "Release" to `3200ms`. Load the included to `polyperc-demo.orca` demo to see more params (be sure to select `PolyPerc` within the params menu first).

- `1`: Pulse width (%)
- `2`: Amp
- `3`: Release (seconds)
- `4`: Cutoff (Hz)
- `5`: Gain
- `6`: Pan
  - values: `0`: left, `i`: center, `z`: right


### MIDI IN

The **MIDI IN** operator `&` takes 1 input(channel).

This operator receives a MIDI note from a MIDI controller, based on the channel value (default is channel 1).


### CC IN

The **CC IN** operator `^` takes 1 input(channel).

This operator receives a MIDI CC message from a MIDI controller, based on the channel value (default is channel 1).


### R.NOTE

The **R.NOTE** operator `$` takes 2 inputs(scale-mode, note).

This operator generates a scale based on the given mode (default is Dorian) and note/key (default is C). For example to generate an F natural minor scale enter `$2F`. There are 35 different modes to choose from:
- `1`: Major
- `2`: Natural Minor
- `3`: Harmonic Minor
- `4`: Melodic Minor
- `5`: Dorian
- `6`: Phrygian
- `7`: Lydian
- `8`: Mixolydian
- `9`: Locrian
- `a`: Gypsy Minor
- `b`: Whole Tone
- `c`: Major Pentatonic
- `d`: Minor Pentatonic
- `e`: Major Bebop
- `f`: Altered Scale
- `g`: Dorian Bebop
- `h`: Mixolydian Bebop
- `i`: Blues Scale
- `j`: Diminished Whole Half
- `k`: Diminished Half Whole
- `l`: Neapolitan Major
- `m`: Hungarian Major
- `n`: Harmonic Major
- `o`: Hungarian Minor
- `p`: Lydian Minor
- `q`: Neapolitan Minor
- `r`: Major Locrian
- `s`: Leading Whole Tone
- `t`: Six Tone Symmetrical
- `u`: Arabian
- `v`: Balinese
- `w`: Byzantine
- `x`: Hungarian Gypsy
- `y`: Persian
- `z`: East Indian Purvi


### LEVELS

The **LEVELS** operator `?` takes 2 inputs(*param*, value).

There are 9 different params that can be modulated on the fly with this operator:
- `1`: level output channels
- `2`: level engine master
- `3`: level softcut master
- `4`: level ADC input
- `5`: reverb engine level
- `6`: softcut reverb level
- `7`: reverb DAC level
- `8`: softcut ADC level
- `9`: softcut engine level

In order to trigger parameter setting a bang `*` has to occure on the left side of operator. The value is simply the percentage to set the level `0` is 0% `z` is 100%. For example `?5z` will set the engine reverb to 100%, or `?2h` will set the engine volume level to 50%.



---

## Demos

When Orca is installed, a number of demos are avaiable to demonstrate basic functionalites.


### synth-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-orca-synth-demo.png)

This demo shows very simply how the **SYNTH** operator `|` works for any of the engines, by randomly selecing notes created with the **TRACK** `T` operator.


### synth-scale-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-orca-synth-scale-demo.png)

This demo shows very simply how the **R.NOTE** operator `$` works, using the **SYNTH** `|` operator to generate the tones using any of the engines.


### fm7-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-fm7-demo.png)

This demo shows the FM7 engine (be sure the FM7 engine is loaded) works using the **SYNTH** `|` operator and how its sound profile can be adjusted with the **SYNTH PARAMS** `-` operator.


### passersby-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-passersby-demo.png)

This demo shows the Passersby engine (be sure the Passersby engine is loaded) works using the **SYNTH** `|` operator and how its sound profile can be adjusted with the **SYNTH PARAMS** `-` operator.


### polyperc-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-polyperc-demo.png)

This demo shows the PolyPerc engine (be sure the PolyPerc engine is loaded) works using the **SYNTH** `|` operator and how its sound profile can be adjusted with the **SYNTH PARAMS** `-` operator.


### import-demo

![307x154,100%](https://frederickk.github.io/orca/screenshot/m-orca-import-demo.png)

This is a text file, similar to what can be found on [PatchStorage](https://patchstorage.com/platform/orca/). Load this demo with the "» Import txt" menu within the main parameters page. Note, this demo uses the MIDI operator `:`, so unless you have a MIDI controller attached you won't hear any sound.







