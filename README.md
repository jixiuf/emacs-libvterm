[![MELPA](https://melpa.org/packages/vterm-badge.svg)](https://melpa.org/#/vterm)

# Introduction

This emacs module implements a bridge to libvterm to display a terminal in an
emacs buffer.

## Warning

This is an **alpha release**, so it will crash your emacs. If it does, please
report a bug!

# Installation

Clone the repository:

```
git clone https://github.com/akermu/emacs-libvterm.git
```

Before installing emacs-libvterm, you need to make sure you have
installed
 1. Emacs with [module
    support](https://www.gnu.org/software/emacs/manual/html_node/elisp/Dynamic-Modules.html).
    You can check that, by verifying that `module-file-suffix` is not `nil`.
 2. cmake (>=3.11)
 3. libtool-bin (related issues: [#66](https://github.com/akermu/emacs-libvterm/issues/66) [#85](https://github.com/akermu/emacs-libvterm/issues/85#issuecomment-491845136))
 4. If you compile vterm with `-DUSE_SYSTEM_LIBVTERM` make sure you have the
    library from https://github.com/neovim/libvterm

Run the build:

```
mkdir -p build
cd build
cmake ..
make
```

And add this to your `init.el`:

``` elisp
(add-to-list 'load-path "path/to/emacs-libvterm")
(require 'vterm)
```

# Debugging and testing

If you have successfully built the module, you can test it by executing the
following command in the `build` directory:

```
make run
```

# Usage

## `vterm`

Open a terminal in the current window.

## `vterm-other-window`

Open a terminal in another window.

## `vterm-copy-mode`

When you enable `vterm-copy-mode`, the terminal buffer behaves like a normal
`read-only` text buffer: you can search, copy text, etc. The default keybinding
is `C-c C-t`.

# Customization

## `vterm-shell`

Shell to run in a new vterm. It defaults to `$SHELL`.

## Keybindings

If you want a key to be sent to the terminal, bind it to `vterm--self-insert`,
or remove it from `vterm-mode-map`. By default, `vterm.el` binds most of the
`C-<char>` and `M-<char>` keys, `<f1>` through `<f12>` and some special keys
like `<backspace>` and `<return>`. Sending a keyboard interrupt is bound to `C-c
C-c`.

## Colors

Set the `:foreground` and `:background` attributes of the following faces to a
color you like. The `:foreground` is ansi color 0-7, the `:background` attribute
is ansi color 8-15.

- vterm-color-default
- vterm-color-black
- vterm-color-red
- vterm-color-green
- vterm-color-yellow
- vterm-color-blue
- vterm-color-magenta
- vterm-color-cyan
- vterm-color-white

## Directory tracking

The `default-directory` would change when you change your working directory.

With `compilation-shell-minor-mode` enabled, you can jump to file references
via `next-error` and `previous-error` like in a `compilation-mode` buffer.



For `zsh` put this in your `.zshrc`:

```zsh
vterm_prompt() {
      print -Pn "\e]51;A$(pwd)\e\\"
}
PROMPT=$PROMPT'%{$(vterm_prompt)%}'

```

If you want to use `compilation-shell-minor-mode`, please use `PROMPT` and not `chpwd` or `preexec`.

For bash 

```bash
PS1='\$ \[\e]51;A$(pwd)\e\\\]'
```
make sure the `\[\e]51;A$(pwd)\e\\\]` is at the end of your prompt

## Remote directory tracking

Put this in your *remote* .zshrc:
```bash
PS1='\$ \[\e]51;A$(whoami)@$(hostname):$(pwd)\e\\\]'
```

```zsh
vterm_prompt() {
    print -Pn "\e]51;A$(whoami)@$(hostname):$(pwd)\e\\"
}
PROMPT=$PROMPT'%{$(vterm_prompt)%}'

```

## Related packages

- [vterm-toggle](https://github.com/jixiuf/vterm-toggle): Toggles between a vterm and the current buffer
- [multi-libvterm](https://github.com/suonlight/multi-libvterm): Multiterm for emacs-libvterm
