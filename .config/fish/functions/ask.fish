function ask -d "Interactive AI assistant. Use -p/--prompt to prepend text to piped input, -q/--quiet for direct output, -h/--help for usage info"
    argparse p/prompt=? q/quiet h/help i/interactive -- $argv
    or return 1

    # Set up cleanup for spinner on exit/interrupt
    set -l spinner_pids
    function cleanup_spinners
        for pid in $spinner_pids
            kill $pid 2>/dev/null
            wait $pid 2>/dev/null
        end
        printf "\r%s\r" (string repeat -n 50 " ") >&2
    end
    trap cleanup_spinners EXIT INT TERM

    if set -q _flag_help
        echo "Usage: ask [OPTIONS] [MESSAGE]"
        echo ""
        echo "Interactive AI assistant that maintains conversation context."
        echo ""
        echo "Options:"
        echo "  -p, --prompt       Prepend text to piped input"
        echo "  -q, --quiet        Suppress formatting and prompts"
        echo "  -i, --interactive  Force interactive mode even with piped input"
        echo "  -h, --help         Show this help message"
        return 0
    end

    # Handle piped input
    if not isatty stdin
        read -z piped_input
    end

    set -l skip_piped_display false
    # Handle prompt flag - if set but empty, prompt for it interactively
    if set -q _flag_prompt; and set -q piped_input
        if test -z "$_flag_prompt"
            # Show piped content and prompt for additional context
            if not set -q _flag_quiet
                echo -n (set_color blue)"Piped:"(set_color normal)
                echo ""
                echo -n "$piped_input"
                echo ""
            end
            printf "%sprompt>%s " (set_color green) (set_color normal)
            read -z user_prompt </dev/tty
            set -l skip_piped_display true
            echo ""
            if test -n "$user_prompt"
                set piped_input (printf "<context>\n%s\n</context>\n\n<query>\n%s\n</query>" "$piped_input" "$user_prompt")
            end
        else
            set piped_input (printf "<instructions>\n%s\n</instructions>\n\n<context>\n%s\n</context>" "$_flag_prompt" "$piped_input")
        end
        # Simple decision logic
    else if test (count $argv) -gt 0
        # Direct message from arguments
        set -l message (string join " " $argv)
        set -l response (command ~/scripts/ask "$message")
        if test $status -eq 0
            if set -q _flag_quiet
                printf "%s" "$response"
            else
                printf "%sAI: %s" (set_color cyan) (set_color normal)
                if command -v glow >/dev/null
                    echo -n "$response" | glow -
                else
                    echo -n "$response"
                end
            end
        end
        return
    else if set -q piped_input; and test -n "$piped_input"; and not set -q _flag_interactive
        # Piped input, non-interactive
        set -l response (command ~/scripts/ask "$piped_input")
        if test $status -eq 0
            if set -q _flag_quiet
                printf "%s" "$response"
            else
                printf "%sAI: %s" (set_color cyan) (set_color normal)
                if command -v glow >/dev/null
                    echo -n "$response" | glow -
                else
                    echo -n "$response"
                end
            end
        end
        return
    end

    # Interactive mode
    set -l chat_history

    # Handle initial message for interactive mode
    set -l initial_message
    if set -q piped_input; and test -n "$piped_input"
        set initial_message "$piped_input"
    else if test (count $argv) -gt 0
        set initial_message (string join " " $argv)
    end

    if set -q initial_message; and test -n "$initial_message"
        if not set -q _flag_quiet; and not test skip_piped_display
            echo -n (set_color blue)"Piped:"(set_color normal)" $initial_message"
        end

        # Start spinner
        fish -c '
            set -l chars "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
            while true
                for char in (string split "" $chars)
                    printf "\r%s%s Thinking...%s" (set_color blue) $char (set_color normal) >&2
                    sleep 0.1
                end
            end
        ' &
        set -l spinner_pid $last_pid
        set -a spinner_pids $spinner_pid

        set -l response (command ~/scripts/ask "$initial_message")
        set -l exit_code $status

        # Stop spinner
        set spinner_pids (string match -v "$spinner_pid" $spinner_pids)
        kill $spinner_pid 2>/dev/null
        wait $spinner_pid 2>/dev/null
        printf "\r%s\r" (string repeat -n 50 " ") >&2

        if test $exit_code -eq 0; and test -n "$response"
            set -a chat_history "You: $initial_message" "AI: $response"

            if not set -q _flag_quiet
                printf "%sAI: %s" (set_color cyan) (set_color normal)
                if command -v glow >/dev/null
                    echo "$response" | glow -
                else
                    echo "$response"
                end
            else
                printf "%s" "$response"
            end
        end
    end

    # Interactive loop
    # if not set -q _flag_quiet
    #     echo "Type your message, press Ctrl+D to send. Press Ctrl+D on empty line to quit."
    # end

    while true
        printf "%sask>%s " (set_color blue) (set_color normal)
        # Reopen stdin from terminal if we had piped input
        if set -q piped_input
            read -z query </dev/tty
        else
            read -z query
        end
        set -l read_status $status

        if test $read_status -ne 0; or test -z "$query"
            break
        end

        if test "$query" = exit
            break
        end

        # Strip trailing newlines from query for comparison
        set -l clean_query (string trim "$query")

        if test "$clean_query" = copy
            if test (count $chat_history) -gt 0
                set -l last_response $chat_history[-1]
                set last_response (string replace -r '^AI: ' '' "$last_response")
                echo -n "$last_response" | command ~/scripts/copy 2>/dev/null
                if test $status -eq 0
                    echo ""
                    echo -n (set_color green)"✅ Copied to clipboard!"(set_color normal)
                else
                    echo (set_color red)"Warning: Failed to copy."(set_color normal)
                end
                echo ""
            else
                echo "No response to copy."
                echo ""
            end
            continue
        end

        # Build full prompt with conversation history
        set -l full_prompt
        if test (count $chat_history) -gt 0
            set -l history_text (string join \n $chat_history)
            set full_prompt (printf "<conversation_history>\n%s\n</conversation_history>\n\n<query>\n%s\n</query>" "$history_text" "$query")
        else
            set full_prompt "$query"
        end
        echo ""

        # Start spinner
        fish -c '
            set -l chars "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
            while true
                for char in (string split "" $chars)
                    printf "\r%s%s Thinking...%s" (set_color blue) $char (set_color normal) >&2
                    sleep 0.1
                end
            end
        ' &
        set -l spinner_pid $last_pid
        set -a spinner_pids $spinner_pid

        set -l response (command ~/scripts/ask "$full_prompt")
        set -l exit_code $status

        # Always stop spinner, even on error
        set spinner_pids (string match -v "$spinner_pid" $spinner_pids)
        kill $spinner_pid 2>/dev/null
        wait $spinner_pid 2>/dev/null
        printf "\r%s\r" (string repeat -n 50 " ") >&2

        if test $exit_code -ne 0
            echo (set_color red)"\nFailed to get response. Please try again."(set_color normal)
            continue
        end

        # Display response
        printf "%sAI: %s" (set_color cyan) (set_color normal)
        if command -v glow >/dev/null
            echo "$response" | glow -
        else
            echo "$response"
        end

        # Update history
        set -a chat_history "You: $query" "AI: $response"
    end

    echo "Exiting ask session."
end
