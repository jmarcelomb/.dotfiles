# Load the (never-committed) MCP token environment for DSH and other tools.
# ~/.dsh/mcp-env uses POSIX KEY=value syntax (sourced by ~/scripts/dsh-web);
# fish cannot source it directly, so parse each assignment here instead.
# Template: ~/.dotfiles/.dsh/mcp-env.example
if test -f ~/.dsh/mcp-env
    for line in (string match -v -r '^\s*(#|$)' < ~/.dsh/mcp-env)
        set -l kv (string split -m 1 '=' -- $line)
        if test (count $kv) = 2
            set -gx $kv[1] $kv[2]
        end
    end
end
