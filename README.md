# F1 TV (webOS)

Unofficial F1TV wrapper for rooted LG webOS TVs, built as a Homebrew Channel
app. Lets you watch F1TV Pro on the TV directly, without Chromecasting from
a phone/laptop.

Not affiliated with Formula 1, F1TV, or Liberty Media. Use at your own risk
— this just points webOS's own browser engine at F1TV's real website; it
doesn't touch F1TV's service, DRM, or account systems in any way.

## How it works

The entire app is a one-line redirect:

```html
<script>location.href = "https://f1tv.formula1.com";</script>
```

That's it — no custom player, no DRM handling written by us. webOS TV's
built-in browser engine (Chromium-based) already supports Widevine DRM
natively (webOS 3.5+), the exact same way a desktop Chrome tab does. F1TV's
own website already handles login, video playback, and DRM licensing itself
— this app just gives it a full-screen, chrome-less window to run in instead
of opening the system Browser app, and each installed app gets its own
persistent cookie storage, so login survives between launches automatically.

This same technique — and the confirmation that it actually works — comes
from [mariovalney/f1tv](https://github.com/mariovalney/f1tv) (this repo
reimplements the same approach independently rather than copying their
files, but full credit for figuring out DRM/login "just works" this way).

## Login autofill (optional)

F1's own session cookies are short-lived (roughly 24 hours), so you end up
back at the login screen fairly often. This app can autofill the
username/password fields the moment F1's login page appears — it never
clicks or submits anything, signing in is still a deliberate, manual last
step.

It's entirely optional: with no credentials file present, the app behaves
exactly as before. To enable it, put a JSON file at
`/var/lib/webosbrew/tv-credentials.json` on the TV (root-only, mode `600`):

```json
{
  "f1tv": {"username": "you@example.com", "password": "your-password"}
}
```

Two ways to get that file onto the TV:

- **Manually**: SSH into the TV as root and write the file yourself.
- **Via [lgtv-playbook](https://github.com/ArnoldDeRuiter/lgtv-playbook)**:
  an Ansible playbook that keeps the credentials encrypted at rest
  (`ansible-vault`) and deploys them for you — also covers
  [family7-webos](https://github.com/ArnoldDeRuiter/family7-webos)'s own
  login autofill from the same file. See that repo's `ansible/` directory.

A background process (`loginfill.py`, started when the app launches)
checks for an existing valid session first and does nothing at all if
you're already logged in. Otherwise it watches for the login form, fills
it once, and exits immediately — it doesn't keep running in the
background for the rest of the session.

## Known limitations

- **No 4K** — same limitation reported by the prior-art project; appears to
  be inherent to how the DRM/player negotiates quality on this platform,
  not something a wrapper can influence either way.
- **Disable Multiview** — if streams don't start, go to
  [F1TV settings](https://f1tv.formula1.com/settings) and turn Multiview
  off. Reported necessary by the prior-art project; not independently
  re-verified here.
- **D-pad navigation** depends entirely on F1TV's own website, not on
  anything this wrapper does — F1TV is built commercially with smart-TV
  clients in mind, so it's reasonably likely to already be keyboard/D-pad
  friendly, but that's F1TV's own responsibility, not something fixable
  from this side if it isn't.
- A **GrandPrixRadio-inside-this-app** integration was considered and is
  **not possible**: F1TV's own CSP (`frame-ancestors 'self'`) and
  `X-Frame-Options: SAMEORIGIN` block this page from being embedded inside
  anything else, including a persistent wrapper UI of our own — the moment
  this redirects to F1TV, our own page/JS is gone. Confirmed via the
  server's actual response headers, not assumed.

## Installing

```sh
./build.sh
```
produces `nl.arnolderuiter.f1tv_<version>_all.ipk`. Install via Homebrew
Channel the normal way (add this repo via `repo.json`, or sideload the ipk
directly).

## License

MIT.
