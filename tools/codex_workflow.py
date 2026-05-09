#!/usr/bin/env python3
"""Small markdown logger for a two-terminal Codex workflow.

This script deliberately does not inspect or wrap a Codex session. It only
records text you provide from a normal shell.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import os
import subprocess
import sys
from pathlib import Path


PROMPT_LATEST = Path("PROMPT_latest.md")
RESPONSE_LATEST = Path("RESPONSE_latest.md")
PROMPTS_USED = Path("PROMPTS_used.md")


def utc_timestamp() -> str:
    return _dt.datetime.now(_dt.timezone.utc).replace(microsecond=0).isoformat()


def entry_id_from_timestamp(timestamp: str) -> str:
    parsed = _dt.datetime.fromisoformat(timestamp)
    return parsed.strftime("%Y%m%dT%H%M%SZ")


def read_clipboard() -> str:
    commands = (
        ("pbpaste",),
        ("wl-paste",),
        ("xclip", "-selection", "clipboard", "-o"),
        ("xsel", "--clipboard", "--output"),
    )
    for command in commands:
        try:
            result = subprocess.run(command, check=True, text=True, capture_output=True)
        except (FileNotFoundError, subprocess.CalledProcessError):
            continue
        return result.stdout
    raise SystemExit("No supported clipboard command found. Pipe text on stdin or use --file.")


def read_input(args: argparse.Namespace) -> str:
    if args.file:
        return Path(args.file).read_text(encoding="utf-8")
    if args.clipboard:
        return read_clipboard()
    if not sys.stdin.isatty():
        return sys.stdin.read()
    raise SystemExit("No input text found. Pipe text on stdin, use --file, or use --clipboard.")


def ensure_trailing_newline(text: str) -> str:
    return text if text.endswith("\n") else text + "\n"


def write_latest(path: Path, title: str, entry_id: str, timestamp: str, body: str) -> None:
    path.write_text(
        f"# {title}\n\n"
        f"- Entry ID: `{entry_id}`\n"
        f"- Recorded: `{timestamp}`\n\n"
        f"{ensure_trailing_newline(body)}",
        encoding="utf-8",
    )


def latest_entry_id() -> str:
    if not PROMPT_LATEST.exists():
        raise SystemExit("PROMPT_latest.md does not exist. Record a prompt first.")
    for line in PROMPT_LATEST.read_text(encoding="utf-8").splitlines():
        if line.startswith("- Entry ID: `") and line.endswith("`"):
            return line.split("`", 2)[1]
    raise SystemExit("Could not find an Entry ID in PROMPT_latest.md.")


def initial_log_text() -> str:
    return (
        "# Codex Prompt Log\n\n"
        "Entries are append-only by default. Edit by hand if needed.\n\n"
    )


def append_prompt_entry(entry_id: str, timestamp: str, prompt: str) -> None:
    if not PROMPTS_USED.exists():
        PROMPTS_USED.write_text(initial_log_text(), encoding="utf-8")

    entry = (
        f"\n## {timestamp} — `{entry_id}`\n\n"
        f"<!-- codex-workflow-entry: {entry_id} -->\n\n"
        "### Prompt\n\n"
        f"{ensure_trailing_newline(prompt)}\n"
        "### Response Summary\n\n"
        f"<!-- codex-workflow-response-start: {entry_id} -->\n"
        "_Pending._\n"
        f"<!-- codex-workflow-response-end: {entry_id} -->\n\n"
        "### Commit\n\n"
        f"<!-- codex-workflow-commit-start: {entry_id} -->\n"
        "_Pending._\n"
        f"<!-- codex-workflow-commit-end: {entry_id} -->\n"
    )
    with PROMPTS_USED.open("a", encoding="utf-8") as handle:
        handle.write(entry)


def replace_marked_block(entry_id: str, kind: str, replacement: str) -> None:
    if not PROMPTS_USED.exists():
        raise SystemExit("PROMPTS_used.md does not exist. Record a prompt first.")

    text = PROMPTS_USED.read_text(encoding="utf-8")
    start = f"<!-- codex-workflow-{kind}-start: {entry_id} -->"
    end = f"<!-- codex-workflow-{kind}-end: {entry_id} -->"
    start_pos = text.find(start)
    if start_pos < 0:
        raise SystemExit(f"Could not find {kind} block for entry {entry_id}.")
    content_start = start_pos + len(start)
    end_pos = text.find(end, content_start)
    if end_pos < 0:
        raise SystemExit(f"Could not find end of {kind} block for entry {entry_id}.")

    new_text = (
        text[:content_start]
        + "\n"
        + ensure_trailing_newline(replacement)
        + text[end_pos:]
    )
    PROMPTS_USED.write_text(new_text, encoding="utf-8")


def command_prompt(args: argparse.Namespace) -> None:
    prompt = read_input(args)
    timestamp = utc_timestamp()
    entry_id = entry_id_from_timestamp(timestamp)
    write_latest(PROMPT_LATEST, "Latest Codex Prompt", entry_id, timestamp, prompt)
    append_prompt_entry(entry_id, timestamp, prompt)
    print(f"Recorded prompt entry {entry_id}.")


def command_response(args: argparse.Namespace) -> None:
    response = read_input(args)
    entry_id = args.entry or latest_entry_id()
    timestamp = utc_timestamp()
    write_latest(RESPONSE_LATEST, "Latest Codex Response Summary", entry_id, timestamp, response)
    replace_marked_block(entry_id, "response", response)
    print(f"Recorded response summary for entry {entry_id}.")


def git_latest_commit() -> tuple[str, str]:
    result = subprocess.run(
        ("git", "log", "-1", "--format=%H%n%s"),
        check=True,
        text=True,
        capture_output=True,
    )
    lines = result.stdout.splitlines()
    if len(lines) < 2:
        raise SystemExit("Could not read the latest git commit hash and subject.")
    return lines[0], lines[1]


def command_commit(args: argparse.Namespace) -> None:
    entry_id = args.entry or latest_entry_id()
    timestamp = utc_timestamp()
    commit_hash = args.hash
    subject = args.subject
    if (commit_hash is None) != (subject is None):
        raise SystemExit("Use --hash and --subject together, or omit both to use git log -1.")
    if commit_hash is None:
        commit_hash, subject = git_latest_commit()

    replacement = (
        f"- Recorded: `{timestamp}`\n"
        f"- Hash: `{commit_hash}`\n"
        f"- Subject: {subject}\n"
    )
    replace_marked_block(entry_id, "commit", replacement)
    print(f"Recorded commit {commit_hash} for entry {entry_id}.")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Record Codex prompts, response summaries, and commits in markdown files."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    for name, help_text in (
        ("prompt", "Record a prompt as the latest prompt and append a new log entry."),
        ("response", "Record a response summary for the latest prompt entry."),
    ):
        subparser = subparsers.add_parser(name, help=help_text)
        subparser.add_argument("--file", help="Read text from this file instead of stdin.")
        subparser.add_argument("--clipboard", action="store_true", help="Read text from the clipboard.")
        if name == "response":
            subparser.add_argument("--entry", help="Entry id to update. Defaults to PROMPT_latest.md.")
        subparser.set_defaults(func=command_prompt if name == "prompt" else command_response)

    commit = subparsers.add_parser("commit", help="Record the latest git commit for an entry.")
    commit.add_argument("--entry", help="Entry id to update. Defaults to PROMPT_latest.md.")
    commit.add_argument("--hash", help="Full commit hash. Defaults to git log -1.")
    commit.add_argument("--subject", help="Commit subject. Defaults to git log -1.")
    commit.set_defaults(func=command_commit)

    return parser


def main(argv: list[str] | None = None) -> int:
    os.chdir(Path(__file__).resolve().parents[1])
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
