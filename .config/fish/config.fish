if status is-interactive
    # Remove default Fish greeting
    set fish_greeting

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
end
