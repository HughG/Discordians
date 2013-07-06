I created some font variants using fontforge 20110222.


I created the -Bold variant using the Set Weight dialog with an em width of
30.


I created the -Condensed variant using the Condense/Extend tool, with

  - for whitespace glyphs,
    - Counters: 100% +/- 0
    - Side Bearings: 95% +/- 0

  - for non-whitespace glyphs,
    - Counters: 85% +/- 0
    - Side Bearings: 80% -20


I created the -Condense-Bold variant from the -Bold variant, using the
Condense/Extend tool, with

  - for whitespace glyphs,
    - Counters: 100% +/- 0
    - Side Bearings: 90% +/- 0

  - for non-whitespace glyphs,
    - Counters: 70% +/- 0
    - Side Bearings: 70% -15

... but I think it needs to be created from a less-bold initial state.
