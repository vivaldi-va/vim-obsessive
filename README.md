# obsessive.vim

An extension on [vim-obsession](https://github.com/tpope/vim-obsession), with centralised session files and project directory creation. By default, vim-obsession creates a `Session.vim` in the current directory, unless a file or directory is specified explicitly. Instead what I'm doing here is creating a central session directory and adding sessions under the "project" directory. For example `~/projects/foo/bar/` would create a session under `~/.nvim/sessions/bar/Session.vim`.

Otherwise, it will work just like `vim-obsession`.

## Installation

**Requirements:**
[vim-obsession](https://github.com/tpope/vim-obsession) should be loaded *before* `vim-obsessive`

**vim-plug**
```
Plug 'tpope/vim-obsession' | Plug 'vivaldi-va/vim-obsessive'
```

**Vundle**
```
Plugin 'vivaldi-va/vim-obsessive'
```

**Pathogen**
```
git clone https://github.comvivaldi-va/vim-obsessive' ~/.vim/bundle/vim-obsessive
```

## Usage

`:Obsess`           - Start session recording, or suspend if already active

`:Obsess!`          - End recording and remote session file

`:ObsessRestore`    - Restore an existing session

also see `:help obsessive`

Bash function to start fresh vim instance with an existing session (Optional):

```bash
vims() {
  # Replace with your defined session directory
  local dir="$HOME/.nvim/session/${PWD##*/}/Session.vim"
  [ -r "$dir" ] && vim -S "$dir" || vim "$@"
}
```

## Config

Set session file storage directory
  `let g:obsessive#dir = '~/.nvim/session'`

Configure airline statusline integration
  `let g:obsessive#airline_enabled = 1`



## Credit

* [Tim Pope](https://github.com/tpope) for the [vim-obsession](https://github.com/tpope/vim-obsession) plugin
