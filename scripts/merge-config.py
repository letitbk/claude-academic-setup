#!/usr/bin/env python3
"""Safely add missing starter settings or instruction sections."""

from __future__ import annotations

import copy
import json
import re
import sys
from pathlib import Path


def add_missing_settings(template: object, existing: object) -> object:
    if not isinstance(template, dict) or not isinstance(existing, dict):
        return copy.deepcopy(existing)
    merged = copy.deepcopy(existing)
    for key, template_value in template.items():
        if key not in merged:
            merged[key] = copy.deepcopy(template_value)
        elif isinstance(template_value, dict) and isinstance(merged[key], dict):
            merged[key] = add_missing_settings(template_value, merged[key])
    return merged


def split_sections(text: str) -> tuple[str, list[tuple[str, str]]]:
    lines = text.splitlines(keepends=True)
    starts = [index for index, line in enumerate(lines) if line.startswith("## ")]
    if not starts:
        return text, []
    preamble = "".join(lines[: starts[0]])
    sections: list[tuple[str, str]] = []
    for position, start in enumerate(starts):
        end = starts[position + 1] if position + 1 < len(starts) else len(lines)
        heading = lines[start].strip()
        sections.append((heading, "".join(lines[start:end]).rstrip() + "\n"))
    return preamble, sections


def merge_instructions(template_text: str, existing_text: str) -> str:
    if not existing_text.strip():
        return template_text
    _, template_sections = split_sections(template_text)
    _, existing_sections = split_sections(existing_text)
    def section_key(heading: str) -> str:
        numbered = re.match(r"^##\s+(\d+)\.", heading)
        if numbered:
            return f"number:{numbered.group(1)}"
        heading_text = heading[3:] if heading.startswith("## ") else heading
        return "heading:" + " ".join(heading_text.lower().split())

    existing_headings = {section_key(heading) for heading, _ in existing_sections}
    additions = [
        body for heading, body in template_sections if section_key(heading) not in existing_headings
    ]
    if not additions:
        return existing_text
    return existing_text.rstrip() + "\n\n" + "\n".join(additions)


def main() -> int:
    if len(sys.argv) != 5:
        print("usage: merge-config.py MODE TEMPLATE EXISTING OUTPUT", file=sys.stderr)
        return 2
    mode, template_name, existing_name, output_name = sys.argv[1:]
    template_path = Path(template_name)
    existing_path = Path(existing_name)
    output_path = Path(output_name)

    if mode == "settings":
        template = json.loads(template_path.read_text())
        existing = json.loads(existing_path.read_text())
        merged = add_missing_settings(template, existing)
        output_path.write_text(json.dumps(merged, indent=2) + "\n")
    elif mode == "instructions":
        merged_text = merge_instructions(template_path.read_text(), existing_path.read_text())
        output_path.write_text(merged_text)
    else:
        print(f"unknown merge mode: {mode}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
