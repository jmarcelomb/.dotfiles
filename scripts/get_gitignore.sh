#!/usr/bin/env bash

function get_gitignore {
  wget -O ".gitignore" "https://raw.githubusercontent.com/github/gitignore/refs/heads/main/$(curl -s "https://api.github.com/repos/github/gitignore/git/trees/main?recursive=true" | jq -r '.tree | .[] | select(.type == "blob") | .path' | fzf)"
}

get_gitignore
