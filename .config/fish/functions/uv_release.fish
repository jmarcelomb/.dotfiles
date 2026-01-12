function uv_release --description "Release a new version"
    set -l new_version $argv[1]

    if test -z "$new_version"
        echo "Error: No version provided."
        echo "Usage: uv_release <version>"
        return 1
    end

    # Update uv version
    uv version $new_version

    # Stage and commit changes
    git add pyproject.toml uv.lock
    git commit -m "chore(release): bump version to v$new_version"

    # Tag the commit with the version
    git tag v$new_version
end
