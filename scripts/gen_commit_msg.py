#!/usr/bin/env -S uv --quiet run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
# ]
# ///

import os
import subprocess
import sys
import argparse


def get_git_diff():
    """Returns the stagea git diff as a string."""
    custom_env = os.environ.copy()
    custom_env["GIT_PAGER"] = "cat"
    result = subprocess.run(
        ["git", "diff", "--cached"],
        capture_output=True,
        text=True,
        check=True,
        env=custom_env,
    )
    return result.stdout.strip()


def prompt_llm(prompt: str, model="qwen2.5-coder:14b", attempts: int = 3):
    messages: list[str] = []
    for _ in range(attempts):
        result = subprocess.run(
            ["ask", model, prompt],
            capture_output=True,
            text=True,
            check=True,
        )
        messages.append(f"{result.stdout.strip()}\n")

    for i, message in enumerate(messages):
        print(f"===Commit message generated #{i} ===")
        print(message)
        print("=" * 40)  # Divider for readability

    while True:
        response = input("Press Enter or write y/yes to continue").strip()

        if response == "" or response.lower() in ("y", "yes"):
            break
        print(f"Aborting commit.. Received '{response}'")
        sys.exit(1)

    subprocess.run(
        ["git", "commit", "-e", "-m", "\n".join(messages)],
        check=True,
    )


def generate_prompt(diff: str, context: str = "", use_emoji: bool = False):
    """Generates a commit message using a local instance of Ollama."""

    if not diff:
        print(
            "Error: The diff is empty. Please stage changes before running.",
            file=sys.stderr,
        )
        sys.exit(1)

    if context:
        context = f"Take into account the following context: {context}."

    identity = "You are to act as an author of a commit message in git."

    commit_preface = (
        """Use GitMoji convention to preface the commit. Here are some help to choose the right emoji:
🐛, Fix a bug;
✨, Introduce new features;
📝, Add or update documentation;
🚀, Deploy stuff;
✅, Add, update, or pass tests;
♻️, Refactor code;
⬆️, Upgrade dependencies;
🔧, Add or update configuration files;
🌐, Internationalization and localization;
💡, Add or update comments in source code;
"""
        if use_emoji
        else """
Do not preface the commit with anything, except for the conventional commit keywords (in lower case):
fix, feat, build, chore, ci, docs, style, refactor, perf, test.
"""
    )

    return f"""
{identity} Your mission is to create clean and comprehensive commit messages
as per the Conventional Commit Convention and explain WHAT were the changes and mainly WHY the changes were done.
I'll send you an output of 'git diff --staged' command, and you are to convert it into a commit message.
{commit_preface}
Add a short description of WHY the changes are done after the commit message.
Don't start it with 'This commit', just describe the changes.
Use the present tense. Lines must not be longer than 74 characters. Use English for the commit message.
{context}

{diff}
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-c", "--context", help="Extra context to feed to prompt.", type=str, default=""
    )
    parser.add_argument(
        "--stdout",
        help="If given, echo's prompt to stdout instead of doing to ollama.",
        action="store_true",
    )
    parser.add_argument(
        "-e", "--emoji", help="Uses emojis if the flag is given.", action="store_true"
    )
    args = parser.parse_args()
    diff = get_git_diff()
    prompt = generate_prompt(diff, args.context, use_emoji=args.emoji)

    if args.stdout:
        print(prompt)
        sys.exit(0)

    prompt_llm(prompt)
    sys.exit(0)


if __name__ == "__main__":
    main()
