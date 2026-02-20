#!/usr/bin/env python3
"""
Quick validation script for skills - no external dependencies
"""

import sys
import re
from pathlib import Path

def parse_frontmatter(content):
    """Parse YAML frontmatter without external dependencies."""
    if not content.startswith('---'):
        return None, "No YAML frontmatter found"
    
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return None, "Invalid frontmatter format"
    
    frontmatter_text = match.group(1)
    frontmatter = {}
    
    for line in frontmatter_text.split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if ':' in line:
            key, value = line.split(':', 1)
            frontmatter[key.strip()] = value.strip()
    
    return frontmatter, None

def validate_skill(skill_path):
    """Basic validation of a skill"""
    skill_path = Path(skill_path)

    skill_md = skill_path / 'SKILL.md'
    if not skill_md.exists():
        return False, "SKILL.md not found"

    content = skill_md.read_text()
    
    frontmatter, error = parse_frontmatter(content)
    if error:
        return False, error
    if not frontmatter:
        return False, "Could not parse frontmatter"

    ALLOWED_PROPERTIES = {'name', 'description', 'license', 'allowed-tools', 'metadata'}
    unexpected_keys = set(frontmatter.keys()) - ALLOWED_PROPERTIES
    if unexpected_keys:
        return False, f"Unexpected key(s): {', '.join(sorted(unexpected_keys))}"

    if 'name' not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if 'description' not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    name = frontmatter.get('name', '').strip()
    if name:
        if not re.match(r'^[a-z0-9-]+$', name):
            return False, f"Name '{name}' should be hyphen-case"
        if name.startswith('-') or name.endswith('-') or '--' in name:
            return False, f"Name '{name}' has invalid hyphen placement"
        if len(name) > 64:
            return False, f"Name too long ({len(name)} chars, max 64)"

    description = frontmatter.get('description', '').strip()
    if description:
        if '<' in description or '>' in description:
            return False, "Description cannot contain angle brackets"
        if len(description) > 1024:
            return False, f"Description too long ({len(description)} chars, max 1024)"

    return True, "Skill is valid!"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        sys.exit(1)
    
    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
