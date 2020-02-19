![orca_norns|690x231,100%](https://llllllll.co/uploads/default/original/3X/e/e/ee7a2a1460ac4c0a54c8a0b067b7e7d9c35f23fd.png)

[Orca](https://100r.co/pages/orca.html) is a visual programming language, designed to create procedural sequencers on the fly.

### Requirements

[Timber engine](https://llllllll.co/t/timber/)


### Documentation

Please refer to original [docs](https://github.com/hundredrabbits/Orca#operators)

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

<!--
Only 1 Engine supported at a time, so Timber is deactivated in favor of PolyPerc
- `'` **timber engine**(*sample* octave note level position): Triggers sample player.
- `"` **timber param**(*sample* *param* value): Sets timber param on bang.
-->
- `/` **softcut**(*playhead* *rec* *play* level rate position)
- `\` **softcut param**(*playhead* *param* value): Sets softcut param on bang
- `>` **g.write**(*x* *y* value): Sets grid led on bang.
- `<` **g.read**(*x* *y*): Reads specific coordinates. If value > 6 outputs bang.
- `:` **midi**(*channel* octave note velocity length): Sends a MIDI note.
- `|` **polyperc**(*octave* *note* release cutoff amp pw gain): Plays a PolyPerc note.
- `%` **mono**(*channel* octave note velocity length): Sends monophonic MIDI note.
- `&` **midi in**(*channel*): Outputs midi note
- `^` **cc in**(*cc*): Outputs midi cc value
- `!` **cc**(*channel* knob value): Sends MIDI control change.
- `=` **OSC** (*path*;x;y..): Locks each consecutive eastwardly ports. `;` is delimeter for values
- `$` **r.note**(mode scale): Outputs random note within scale.
- `?` **levels**(*param* value): Sets selected volume level on bang
