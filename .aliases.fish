# Check if eza exists and alias ls to eza
if type -q eza
    alias ls="eza"
end

# Check if zoxide exists and alias cd to zoxide
if type -q zoxide
    alias cd="z"
end

# Check if bat exists and alias cat to bat
if type -q bat
    alias cat="bat --style=plain --paging=never"
    alias less='bat --paging=always'
    alias bathelp='bat --plain --language=help'

    function help
        "$argv" --help 2>&1 | bathelp
    end
    alias h='help'
end

source ~/.aliases.common
