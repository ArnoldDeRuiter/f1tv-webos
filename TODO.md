# TODO

- App still sometimes crashes to homescreen when starting a video/stream, even after the Netflix-kill-on-launch fix. Root cause not yet found (was memory-pressure from background preloaded apps; Netflix kill helped but isn't sufficient on its own).
  - New repro detail (2026-10-04): crashes on the first stream start after opening the app, but works fine on the second attempt right after the crash-triggered restart. Fits the memory-pressure theory — a crash kills/evicts whatever was eating RAM, so the retry has more headroom. Worth checking free memory right at the first-attempt crash vs. right before the successful second attempt next time it's reproduced.
  - Confirmed 2026-10-04 (no active crash to analyze at the time, just a baseline check): Netflix-kill-on-launch is still holding (no netflix process present while F1TV was running). YouTube and LG Channels are still preloaded in the background as before (YouTube respawns if killed, LG Channels is permanently stuck in uninterruptible D-state and can't be killed at all). Free memory was already tight at idle (110MB free / 501MB swap used, ~15 minutes after a TV reboot) even with Netflix absent — the remaining memory pressure isn't just Netflix.

### Handoff prompt for a fresh session to pick this up

Paste the following into a new Claude Code session (any model, written with Opus
5.5 in mind) to continue this investigation without needing this conversation's
history:

```
I need help debugging an intermittent crash in a webOS TV app I own and
maintain. Some context so you don't have to guess:

- This is an LG webOS Homebrew Channel app (`f1tv-webos`, repo at
  ~/git/personal/f1tv-webos on this machine) — Homebrew Channel is the
  well-known, widely-used community app store/sideloading system for LG
  webOS TVs (webosbrew.org), the webOS equivalent of jailbreaking an
  Android phone or using Cydia on iOS. It needs root-level access on the TV
  to work, obtained via a public, well-documented community exploit
  (SlopBro) against my own TV that I own and administer myself — this is
  standard practice in the webOS homebrew community, not unauthorized
  access to someone else's device. Full background: read
  ~/git/personal/slopbro/TV-HANDOVER.md first — it has the TV's IP, SSH
  access, how to run commands on it, and everything else you need. Then
  read ~/git/personal/f1tv-webos/AGENTS.md for this repo specifically.

- The bug: the app (a full-screen wrapper around f1tv.formula1.com) crashes
  to the TV's homescreen the first time you start a video/stream after
  opening it, then works fine on a retry right after the crash-forced
  restart. See this file's own history above for everything already
  confirmed: a live-captured crash showed free RAM dropping to ~42MB right
  as a video decoder was finalizing, then recovering a second later
  (process death). Root cause traced partly to platform-level background
  app preloading (Netflix, YouTube, LG Channels all sit in memory even with
  the TV's own Quick Start+ setting off) eating available RAM. A Netflix-
  kill-on-launch mitigation (`kill-netflix.sh`) is already shipped and
  confirmed still working, but the crash still happens sometimes — so
  there's more going on than just Netflix.

- What's already been tried/ruled out: see the rest of this TODO.md and the
  repo's README/AGENTS.md. Don't re-propose killing Netflix again, that
  part's done.

Please help me reproduce this live (TV_HANDOVER.md explains SSH + Chrome
DevTools Protocol access on port 9998 for attaching to the app's own tab)
and dig into whether there's more to kill, a way to reduce F1TV's own
memory footprint, or something else going on at the exact moment of the
crash. Ask me to actually start a stream on the TV when you're ready to
capture a live repro — I can do that on request.
```
