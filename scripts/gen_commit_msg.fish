#!/usr/bin/env fish
### Uses local instance of ollama to generate commit messages.
### First add/stage the changes you want to generate the commit for.
### It generates 3 commit message and then you can choose the one you want.

function gen_commit_msg --argument context
    set -l model "deepseek-coder-v2:16b"
    set -l use_emoji no
    set -l attempts 3

    function print_help -a msg -V script_name
        if test -n "$msg"
            set_color red
            echo "$msg"
        end
        set_color yellow
        echo "Usage:"
        echo "  `git add` the files to the staging area"
        echo "  then run the script, optionally passing in a context string."
    end

    set gitDiff (git diff --cached | string collect)
    if test -z "$gitDiff"
        print_help "The diff is empty."
        return 1
    end

    if test -n "$context"
        set context "Take into account the following context: $context."
    end

    set codeblocked_git_diff "```
$gitDiff```"
    set identity "You are to act as an author of a commit message in git."

    if test "$use_emoji" = yes
        set commit_preface "Use GitMoji convention to preface the commit. Here are some help to choose the right emoji (emoji, description):
🐛, Fix a bug;
✨, Introduce new features;
📝, Add or update documentation;
🚀, Deploy stuff;
✅, Add, update, or pass tests;
♻️, Refactor code;
⬆️, Upgrade dependencies;
🔧, Add or update configuration files;
🌐, Internationalization and localization;
💡, Add or update comments in source code;"
    else
        set commit_preface "Do not preface the commit with anything, except for the conventional commit keywords (in lower case): fix, feat, build, chore, ci, docs, style, refactor, perf, test."
    end

    set prompt "$identity Your mission is to create clean and comprehensive commit messages as per the Conventional Commit Convention and explain WHAT were the changes and mainly WHY the changes were done.
I'll send you an output of 'git diff --staged' command, and you are to convert it into a commit message.
$commit_preface
Add a short description of WHY the changes are done after the commit message. Don\'t start it with 'This commit', just describe the changes.
Use the present tense. Lines must not be longer than 74 characters. Use english for the commit message.
$context

$gitDiff"


    set answer (for i in (seq $attempts)
        ask "$model" "$prompt"
    end | string collect)
    git commit -e -m "$answer"
    # set -Ux COMMIT_MSG "$answer"
end

gen_commit_msg "$argv"
