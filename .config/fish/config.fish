if ! status is-interactive
    return
end

# Remove default Fish greeting
set fish_greeting

fish_vi_key_bindings

# search history with Control-R when in insert mode
bind --mode insert \cr history-pager
set fish_escape_delay_ms 10

# Emulates vim's cursor shape behavior
set fish_cursor_default block # set the normal and visual mode cursors to a block
set fish_cursor_insert line # set the insert mode cursor to a line
set fish_cursor_visual block # Set the visual mode cursor to a block
# Set the replace mode cursor to an underscore
set fish_cursor_replace underscore
set fish_cursor_replace_one underscore

# Setting this because fish's fish_vi_cursor is not detecting ghostty's term capabilities
set fish_vi_force_cursor

# PATH setup
fish_add_path --prepend --move \
    /usr/local/bin \
    /opt/homebrew/bin \
    /etc/profiles/per-user/$USER/bin \
    $HOME/bin \
    $HOME/.local/bin \
    $HOME/scripts \
    $HOME/Tools/fzf/bin \
    $HOME/Tools/neovim/bin \
    $HOME/go/bin \
    $HOME/.cargo/bin \
    $HOME/.atuin/bin \
    $HOME/.opencode/bin

# Default editor
set -gx EDITOR nvim

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

if type -q uv
    uv generate-shell-completion fish | source
end

if type -q glow
    glow completion fish | source
end

# fzf key bindings and fuzzy completion
if type -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_OPTS "--bind 'f2:toggle-preview'"
    set -gx FZF_DEFAULT_COMMAND "fd --no-ignore --hidden --strip-cwd-prefix --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND "fd --no-ignore --type=d --hidden --strip-cwd-prefix --exclude .git"

    set -gx FZF_CTRL_T_OPTS "--no-height --no-reverse --preview 'bat -n --color=always --line-range :500 {}'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

    if ! type -q atuin
        set -gx FZF_CTRL_R_OPTS "--no-sort --exact"
    end
end

if type -q atuin
    atuin init fish | source
end

# Source additional configurations
test -f ~/.aliases.fish && source ~/.aliases.fish
