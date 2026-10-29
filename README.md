<div align="center">
  <img src="assets/logo.svg" alt="macmini-tmux" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-CLI%20Tool-0D9488)](#)

  [简体中文](README_cn.md)
</div>

# macmini-tmux

> One command to reach tmux on the Mac mini: session names are numbered automatically, so there is nothing to invent and nothing to collide with.

## Why

When the Mac mini doubles as a remote dev box, the routine step is "get in and open a tmux session that survives disconnects." Plain `ssh` + `tmux` has two rough edges:

- You have to remember a session name. Pick one that already exists and `tmux new -s` fails with `duplicate session`, so you stop and think up another;
- `ssh -t` is easy to forget. Without `-t` there is no tty, and tmux dies with `open terminal failed` — a message that means little if you rarely use tmux.

`macmini-tmux` folds both into one command: no arguments means "start a fresh one", and the script hands out the next free number (`session#1`, `session#2`, …) so there is no name to remember. To go back to an older session, attach it by name or just take the most recent one.

## Usage

| Command | What it does |
|---|---|
| `macmini tmux` | Start a **new session** with the smallest free number (`session#1`, `session#2`, …); the chosen name is printed before attaching |
| `macmini tmux -s dev` | Attach to `dev`; create it if missing (use this to reconnect, or for a fixed workspace) |
| `macmini tmux dev` | Same as above, with `-s` omitted |
| `macmini tmux -a` | Attach to the session you **entered most recently** |
| `macmini tmux -l` | List the tmux sessions on the Mac mini |
| `macmini df -h` | Skip tmux entirely and run the command on the Mac mini |
| `macmini -h` | Show help |

A `#` inside a session name is perfectly legal — verified on tmux 3.6b locally and tmux 3.3a on the Mac mini.

## Install

```bash
git clone https://github.com/xhqing/macmini-tmux.git
cd macmini-tmux
./install.sh
```

The script copies `macmini` to `~/.local/bin/macmini` (`BIN_DIR=/usr/local/bin ./install.sh` installs elsewhere). It is a **copy, not a symlink**: what you run day to day is the deployed copy, so edits in the repo take effect only after re-running `install.sh`. Work in progress never changes the command you rely on.

## Numbering rules

New names climb from `session#1` and take **the first free number**:

| Existing sessions | Next new session |
|---|---|
| none | `session#1` |
| `session#1` | `session#2` |
| `session#1`, `session#2` | `session#3` |
| `session#1`, `session#3` (2 was killed) | `session#2` (gaps get reused) |

Sessions with other names (say a `work` session you created by hand) are ignored by the numbering and never disturb the sequence.

## How `-a` chooses

It takes the largest `session_last_attached` — the time you last attached to that session, i.e. the last time you stepped into it. Sessions that were never attached (created in the background with `tmux new -d`) have no such value, so those fall back to `session_activity` (last activity).

In other words, "most recently used" means **the one you entered last**, not the busiest one.

## Why the status bar shows `session#10`

The left side of the tmux status bar defaults to `[session-name] `, and `status-left-length` caps it at **10 characters**. `session#1` plus brackets and the trailing space is 12 characters, so it gets cut down to `[session#1` (losing the `]` and the space); the window list `0:zsh*` then sits right next to it and the result reads `session#10:zsh*`.

That trailing `0` is not part of the name — it is **window index 0**. Raise the limit in `~/.tmux.conf`:

```tmux
set -g status-left-length 40
```

Then run `tmux source-file ~/.tmux.conf`; it applies immediately, no need to restart anything.

## Another host or SSH alias

The script targets `mac-mini` (the Host alias in `~/.ssh/config`) by default. To point at the same machine through a different alias, override it with an environment variable:

```bash
MACMINI_HOST=mac-mini-lan macmini tmux
```

## Requirements

- macOS (the script relies on bash and `ssh -t`; tmux itself is cross-platform, but Windows is not handled)
- tmux installed on the target machine
- passwordless SSH (a `Host mac-mini` entry plus a key in `~/.ssh/config` is the tidy way)
- a larger `status-left-length` in `~/.tmux.conf` on either side, so session names are not truncated

## Related

This repository is a subproject of [ExecutiveAssistantAgent](https://github.com/xhqing/ExecutiveAssistantAgent) (Kit). The `AGENTS.md` and `.pi` entries at the repo root are symlinks back to that agent project, so a session opened in this directory inherits the same rules and skills.

## License & Attribution

Copyright (c) 2026 All Contributors. Released under the [MIT License](LICENSE.md).

Attribution: if you use or reference this project, please keep the copyright notice and credit the source: [macmini-tmux](https://github.com/xhqing/macmini-tmux).
