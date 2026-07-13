# dotfiles

Personal configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Cloning this repo onto a new machine and stowing the packages recreates my
shell, editor, multiplexer, and Git setup with minimal fuss.

## How this repo is laid out

Each top-level directory is a **stow package**. Its internal structure mirrors
your home directory, and Stow creates symlinks from `$HOME` into this repo.

```
dotfiles/
├── bash/                 -> package "bash"
│   └── .bashrc               ~/.bashrc
├── git/                  -> package "git"
│   └── .gitconfig            ~/.gitconfig
├── nvim/                 -> package "nvim"
│   └── .config/nvim/...      ~/.config/nvim/...
└── tmux/                 -> package "tmux"
    └── .tmux.conf            ~/.tmux.conf
```

So `stow nvim` symlinks `~/.config/nvim` → `dotfiles/nvim/.config/nvim`.

## How Stow decides what to symlink (tree folding)

You may notice Stow links a single **file** for the `git` package but a whole
**directory** for `nvim`. It's due to an algorithm
called **tree folding**: Stow creates a symlink at the *shallowest point where
the target path doesn't already exist*. The question is not "file or
directory?", it's "how deep do I have to descend before I hit something that's
already there?"

**`git` package** - `dotfiles/git/.gitconfig` → `~/.gitconfig`

To link the top-level `git/` folder, Stow would have to create the link at `~`
itself, but `~` already exists. So it descends into `~` and links the next
level: the file `.gitconfig`. It stopped at a file only because everything
above it already existed.

**`nvim` package** - `dotfiles/nvim/.config/nvim/...` → `~/.config/nvim`

- `~` exists → descend
- `~/.config` exists (many apps use it) → descend
- `~/.config/nvim` does **not** exist yet → **stop and link the whole directory**

Stow "folds" the entire subtree into a single symlink. If `~/.config/nvim` had
already existed as a real directory, Stow would descend further and link each
file individually instead.

```
~ (exists)          ~/.config (exists)          ~/.config/nvim (missing) → link whole dir
~ (exists)          .gitconfig (missing) → link the file
```

## Prerequisites

- `git`
- `stow` - GNU Stow is a Linux/macOS/WSL tool. On Windows, run these steps
  from **WSL**

## Applying the dotfiles on a new machine

```bash
# 1. Clone the repo into your **home directory**
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# 2. Stow the packages you want (creates symlinks in $HOME)
stow bash
stow nvim
stow tmux
stow git

# ...or stow everything at once
stow */
```

By default Stow targets the parent of the current directory. Since the repo is
cloned at `~/dotfiles`, the target is `~`, which is what we want. To be explicit:

```bash
stow --target="$HOME" nvim
```

### Handling conflicts with existing files

Stow refuses to overwrite a real file that isn't already its symlink. If you
already have, say, a `~/.bashrc`, either back it up first:

```bash
mv ~/.bashrc ~/.bashrc.backup
stow bash
```

...or let Stow **adopt** the existing file into the repo (moves the file into
the package, then symlinks it back). Review the diff afterwards:

```bash
stow --adopt bash
git diff          # inspect what adopt pulled in; reset if unwanted
```

## The `git` package (important)

`git/.gitconfig` holds only **portable** settings (line-endings, filemode,
aliases). Machine-specific settings - your identity and credential helpers -
live in `~/.gitconfig.local`, which is **not** tracked here. The base config
includes it automatically.

After `stow git`, create the local override on each machine:

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
	name = Utkarsh Saxena
	email = utsaxena@microsoft.com   # or your personal email on a personal box

[credential]
	helper = manager-core            # Windows/WSL: git-credential-manager
EOF
```

> Tip: to use different emails for work vs personal repos automatically, use
> conditional includes in `~/.gitconfig.local`:
> ```ini
> [includeIf "gitdir:~/personal/"]
>     path = ~/.gitconfig-personal
> ```

## Everyday commands

```bash
# Re-apply after editing files or adding new ones in a package
stow -R nvim          # restow (unstow + stow)

# Remove a package's symlinks (does not delete the repo files)
stow -D tmux          # delete/unstow

# Preview changes without touching the filesystem
stow -nv nvim         # dry-run, verbose
```