# Latest Codex Response Summary

- Entry ID: `20260510T044611Z`
- Recorded: `2026-05-10T04:49:04+00:00`

Updated the default macro support for `nice_text()`.

What changed:
- Replaced [inst/tex/default-macros.tex](/Users/earn/r/earnmisc/inst/tex/default-macros.tex) with your curated cross-package plot-label macro list exactly as provided.
- Removed the old arbitrary defaults `\I`, `\E`, and `\dd`.
- Updated `nice_text_macros()` documentation to describe the default macro file as curated earnmisc plot-label notation, not a full manuscript preamble.

Parser changes:
- No parser code changes were needed. The existing `remove_tex_comment()` already strips unescaped inline `%` comments before parsing.
- Verified that `\newcommand{\xp}{x^{+}} %{\infty}}` parses as `x^{+}`.

Tests revised:
- `nice_text_macros()` now checks the full curated default macro name set.
- Added checks that `\FoI` is included.
- Added checks that old defaults `\I`, `\E`, and `\dd` are absent.
- Added recursive expansion checks for `\Rn`, `\tinc`, `\tFoIpeak`, and `\Xkm`.
- Added inline-comment parsing coverage for `\xp`.
- Existing tests still cover user macro append, override, and `append.macros = FALSE`.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitations remain the same: macro support is intentionally limited to simple no-argument definitions and bounded recursive expansion, not full TeX parsing.
