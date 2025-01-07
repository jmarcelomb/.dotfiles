if ! status is-interactive

end

# Remove default Fish greeting
set fish_greeting

fish_vi_key_bindings

# search history with Control-R when in insert mode
bind --mode insert \cr 'history-pager'
set fish_escape_delay_ms 10

# Emulates vim's cursor shape behavior
set fish_cursor_default block # set the normal and visual mode cursors to a block
set fish_cursor_insert line   # set the insert mode cursor to a line
set fish_cursor_visual block  # Set the visual mode cursor to a block
# Set the replace mode cursor to an underscore
set fish_cursor_replace underscore
set fish_cursor_replace_one underscore

# Setting this because fish's fish_vi_cursor is not detecting ghostty's term capabilities
set fish_vi_force_cursor

# PATH setup
set PATH /usr/local/bin $PATH
set PATH /opt/homebrew/bin $PATH
set PATH $HOME/bin $PATH
set PATH $HOME/.local/bin $PATH
set PATH $HOME/Tools/fzf/bin $PATH
set PATH $HOME/Tools/neovim/bin $PATH
set PATH $HOME/go/bin $PATH
set PATH $HOME/.cargo/bin $PATH
set PATH $HOME/scripts $PATH

# Export the updated PATH
set -Ux PATH $PATH

# Default editor
set -Ux EDITOR nvim

# Starship prompt initialization
if type -q starship
    starship init fish | source
end

# direnv initialization
if type -q direnv
    direnv hook fish | source
end

# zoxide initialization
if type -q zoxide
    zoxide init fish | source
end

# fzf key bindings and fuzzy completion
if type -q fzf
    set -U FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
    set -U FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -U FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    set -U FZF_CTRL_T_OPTS "--preview 'bat -n --color=always --line-range :500 {}'"
    set -U FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"
end

# Custom function for yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Source additional configurations
for config_file in ~/.fzf.fish ~/.aliases.fish
    if test -f $config_file
        source $config_file
    end
end
