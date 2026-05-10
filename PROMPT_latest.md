# Latest Codex Prompt

- Entry ID: `20260510T044611Z`
- Recorded: `2026-05-10T04:46:11+00:00`

Please update the default TeX macro support for `earnmisc::nice_text()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Replace the current package default macro file with my curated default macro list.

The file is:

```text
inst/tex/default-macros.tex
```

This file should reflect my stable cross-package plot-label notation. Do not add generic mathematical macros just because they seem common. In particular, do not re-add arbitrary defaults such as `\I`, `\E`, or `\dd` unless they appear explicitly below.

## New default macro file

Replace the contents of `inst/tex/default-macros.tex` with exactly this content:

```tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Conservative no-argument macros for earnmisc::nice_text() %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% basic reproduction number
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
%% incidence
\newcommand{\inc}{\iota}
%% Force of Infection
\newcommand{\FoI}{F}
%% Kermack and McKendrik
\newcommand{\kmsubscript}{\text{\scalebox{0.6}{\mathrm{KM}}}}
\newcommand{\Xkm}{\tX_{\kmsubscript}}
\newcommand{\Ykm}{\tY_{\kmsubscript}}
\newcommand{\Zkm}{\tZ_{\kmsubscript}}
%% approximate quantities
\newcommand{\tX}{\tilde{X}}
\newcommand{\tY}{\tilde{Y}}
\newcommand{\tZ}{\tilde{Z}}
\newcommand{\tinc}{\tilde{\inc}}
%% asymptotic values
\newcommand{\xp}{x^{+}} %{\infty}}
\newcommand{\xm}{x^{-}} %{-\infty}}
\newcommand{\zp}{z^{+}} %{\infty}}
\newcommand{\zm}{z^{-}} %{-\infty}}
\newcommand{\xpm}{x^\pm}
\newcommand{\xmp}{x^\mp}
\newcommand{\Xpm}{X^{\pm}}
%% multi-functions
\newcommand{\Xp}{X^{+}}
\newcommand{\Xm}{X^{-}}
%% exponential rates
\newcommand{\lamp}{{\lambda^{\!{+}}}}
\newcommand{\lamm}{{\lambda^{\!{-}}}}
\newcommand{\lampm}{\lambda^{\!{\pm}}}
\newcommand{\lammp}{\lambda^{\!{\mp}}}
\newcommand{\lambdakm}{\lambda_{\kmsubscript}}
%% peak values
\newcommand{\xpeak}{\hat{x}}
\newcommand{\ypeak}{\hat{y}}
\newcommand{\zpeak}{\hat{z}}
\newcommand{\taupeak}{\hat{\tau}}
\newcommand{\taupeakkm}{\taupeak_{\kmsubscript}}
\newcommand{\ypeakkm}{\ypeak_{\kmsubscript}}
\newcommand{\xpeakkm}{\xpeak_{\kmsubscript}}
\newcommand{\tFoIpeak}{\hat{\tilde{\FoI}}}
\newcommand{\tincpeak}{\hat{\tilde{\inc}}}
%% age of infection
\newcommand{\aoi}{\alpha}
%% Lambert W function
\newcommand{\Wp}{W_{\!+}}
\newcommand{\Wm}{W_{\!-}}
\newcommand{\Wpm}{W_{\!\pm}}
%% initial conditions
\newcommand{\tauinit}{\tau_{\mathrm{i}}}
\newcommand{\xinit}{x_{\mathrm{i}}}
\newcommand{\yinit}{y_{\mathrm{i}}}
\newcommand{\zinit}{z_{\mathrm{i}}}
%% order of magnitude
\newcommand{\Oh}{{\mathcal O}}
%% sets
\newcommand{\reals}{{\mathbb R}}
\newcommand{\integers}{{\mathbb Z}}
\newcommand{\naturals}{{\mathbb N}}
%% stage durations
\newcommand{\Tinf}{T_{\mathrm{inf}}}
\newcommand{\Tlat}{T_{\mathrm{lat}}}
%% entering boundary layer
\newcommand{\xin}{x_{\mathrm{in}}}
```

## Important parser expectations

The macro parser currently supports simple no-argument TeX macros. Please ensure it continues to parse this file correctly.

The parser should ignore comment lines and inline comments appropriately.

For example, lines such as:

```tex
\newcommand{\xp}{x^{+}} %{\infty}}
```

should define `\xp` as:

```tex
x^{+}
```

not include the trailing comment.

If the current parser does not strip inline comments safely, please fix that conservatively.

## Tests

Update or add tests so that:

- `nice_text_macros()` includes all macros from the new default file.
- `nice_text_macros()` includes `\FoI`.
- `nice_text_macros()` does not include arbitrary old defaults such as `\I`, `\E`, or `\dd`.
- selected recursive expansions work, including:
  - `\Rn`, which depends on `\R`;
  - `\tinc`, which depends on `\inc`;
  - `\tFoIpeak`, which depends on `\FoI`;
  - `\Xkm`, which depends on `\tX` and `\kmsubscript`.
- inline comments do not become part of macro replacement text.
- user-supplied macro files can still append to these defaults.
- user-supplied macro files can still override these defaults.
- `append.macros = FALSE` still replaces the package defaults.

Avoid brittle tests that require `latex2exp` to fully understand every TeX command in this file. It is fine to test macro parsing and expansion through internal helpers if that is the most stable approach.

## Documentation

Update documentation only if needed.

The documentation should make clear that:

- the default macro file is a curated `earnmisc` default;
- it is intentionally not a full manuscript preamble;
- users can append or replace it with `macros.file`, `append.macros`, and `options(earnmisc.tex_macros_file = ...)`.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What changed in `inst/tex/default-macros.tex`.
2. Whether the parser needed changes for comments or inline comments.
3. What tests were added or revised.
4. What verification commands were run and their results.
5. Any limitations or TODOs.
