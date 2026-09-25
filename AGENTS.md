# AGENTS.md

Read `~/git/personal/slopbro/TV-HANDOVER.md` first for the TV's IP/SSH
access, CDP, root exec bridge, and standing rules. This file covers what's
specific to this repo.

## What this is

`type: web` Homebrew app (`nl.arnolderuiter.f1tv`) — full-screen wrapper
around f1tv.formula1.com. Login autofill (`loginfill.py`, background daemon
started via the root exec bridge from `index.html`) and a Netflix-kill on
launch (`kill-netflix.sh`, chained the same way) to mitigate a real
memory-pressure crash. See `TODO.md` for the open crash bug — Netflix-kill
helped but isn't fully sufficient yet.

## Build

```sh
sh build.sh
```

Hand-rolled `.ipk` (`ar`+`tar`, no `ares-cli`), version read from
`appinfo.json`. **Don't hand-bump the version** — releases are tagged, and
CI auto-derives the version from the tag into a fresh `appinfo.json` at
build time (no git push-back). The local `appinfo.json` version is stale by
design.

## Testing changes live (do this before committing anything TV-facing)

```sh
scp index.html loginfill.py kill-netflix.sh start-loginfill.sh \
  tvtje:/media/developer/apps/usr/palm/applications/nl.arnolderuiter.f1tv/
ssh tvtje 'rm -f /tmp/f1tv-loginfill.log /tmp/f1tv-loginfill.pid'
```

Then relaunch the app on the TV and check
`ssh tvtje 'cat /tmp/f1tv-loginfill.log'` plus whatever else the change
touches. Only commit after confirming it actually works on the real device.

## Gotchas specific to this app

- `AUTH_COOKIE_NAME` for the session check is `entitlement_token`, **not**
  `login` — `login`/`user-metadata` linger stale even after logout and will
  give false "already logged in" positives.
- Exec-bridge command chains must be `"sh a.sh; sh b.sh"` shape throughout —
  a bare non-`sh`-prefixed first command in the chain can silently fail
  (see TV-HANDOVER.md).

## Rules

- Never `git push` — Captain pushes himself.
