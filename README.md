# Gradle Wrapper Completion via fzf (Zsh)

A lightweight, project-local Zsh completion UI for `./gradlew` / `gradlew` powered by **fzf**, featuring:

- **TAB** to open a searchable list of tasks/options
- **Type-ahead filtering** (last token becomes initial fzf query)
- **No computation by default** the completion shows default entries by default
- **Ctrl+R refresh** to get all available completion proposals. Updates the cache in the background while the UI stays usable

---

## Requirements

### Runtime dependencies

- **zsh**
  - The script must be **sourced** by zsh.
  - Uses ZLE widgets and `${(z)}` word splitting.

- **fzf** (must support `--listen`)
  - Unix domain socket mode requires **fzf ≥ 0.66.0** (use `--listen <path>.sock`).
  - Older versions use TCP mode (`--listen 127.0.0.1:<port>`).
  - Refresh relies on posting actions to the running fzf instance (`reload(...)`, `change-header(...)`).

- **curl ≥ 7.40.0**
  - Required for `--unix-socket` support (Unix socket mode).
  - Also used for HTTP POST when TCP listen mode is active.

---

## Installation

1. Put the completion script somewhere on disk, for example:

   ```sh
   ~/bin/zsh-fzf-gradle-completion
   ```

2. Source it from your `~/.zshrc`:

   ```sh
   source ~/bin/zsh-fzf-gradle-completion
   ```

3. Restart your shell (or run `source ~/.zshrc`).

---

## Activation rules

The completion activates only when:

1. The left buffer (text before the cursor) begins with `gradlew` or `./gradlew`.

2. The current directory contains an **executable Gradle wrapper**:

If these conditions are not met, TAB falls back to the default Zsh completion (`expand-or-complete`).


