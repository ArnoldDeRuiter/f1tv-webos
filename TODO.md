# TODO

- App still sometimes crashes to homescreen when starting a video/stream, even after the Netflix-kill-on-launch fix. Root cause not yet found (was memory-pressure from background preloaded apps; Netflix kill helped but isn't sufficient on its own).
  - New repro detail (2026-10-04): crashes on the first stream start after opening the app, but works fine on the second attempt right after the crash-triggered restart. Fits the memory-pressure theory — a crash kills/evicts whatever was eating RAM, so the retry has more headroom. Worth checking free memory right at the first-attempt crash vs. right before the successful second attempt next time it's reproduced.
