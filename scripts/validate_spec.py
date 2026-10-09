#!/usr/bin/env python3
"""Validate the mechanical structure and local links of docs/spec."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import unquote, urlsplit


USE_CASE_RE = re.compile(r"^(\d{3})-(.+)\.md$")
USE_CASE_LINK_RE = re.compile(r"^\*\*Use Case:\*\*\s*\[[^]]+\]\(([^)]+)\)\s*$")
STATUS_RE = re.compile(r"^\*\*Status:\*\*\s*(Draft|Review|Approved|Implemented)\s*$")
MARKDOWN_LINK_RE = re.compile(r"\[([^]]+)\]\(([^)]+)\)")
ENTRY_RE = re.compile(r"^\*\*Entry:\*\*\s*(.+?)\s*$")
USE_CASE_BULLET_RE = re.compile(r"^-\s+\[[^]]+\]\(([^)]+)\)\s*$")
REQUIRED_USE_CASE_SECTIONS = (
    "Goal",
    "Actors",
    "Preconditions",
    "Trigger",
    "Behavior Diagrams",
    "Flow",
    "Postconditions",
)


@dataclass(frozen=True)
class UseCase:
    path: Path
    sequence: str
    slug: str


@dataclass(frozen=True)
class Record:
    path: Path
    sequence: str
    slug: str


class Validation:
    def __init__(self, repo_root: Path, spec_root: Path) -> None:
        self.repo_root = repo_root
        self.spec_root = spec_root
        self.errors: list[str] = []

    def error(self, path: Path, message: str, line: int | None = None) -> None:
        rel = path.relative_to(self.repo_root) if path.is_relative_to(self.repo_root) else path
        suffix = f":{line}" if line else ""
        self.errors.append(f"{rel}{suffix}: {message}")

    def run(self, domain_name: str | None) -> None:
        if not self.spec_root.is_dir():
            self.errors.append(f"spec root does not exist: {self.spec_root}")
            return
        catalog = self.spec_root / "catalog.md"
        if not catalog.is_file():
            self.error(catalog, "missing root catalog")
        domains = [self.spec_root / domain_name] if domain_name else sorted(
            p for p in self.spec_root.iterdir() if p.is_dir()
        )
        for domain in domains:
            if not domain.is_dir():
                self.errors.append(f"domain does not exist: {domain}")
                continue
            self.validate_domain(domain)
        link_root = self.spec_root if domain_name is None else self.spec_root / domain_name
        for path in sorted(link_root.rglob("*.md")):
            self.validate_local_links(path)

    def validate_domain(self, domain: Path) -> None:
        domain_document = domain / "domain.md"
        entity_model = domain / "entity-model.md"
        if not domain_document.is_file():
            self.error(domain_document, "missing domain document")
        if not entity_model.is_file():
            self.error(entity_model, "missing Entity Model")

        use_cases: dict[tuple[str, str], UseCase] = {}
        sequences: dict[str, Path] = {}
        for path in sorted(domain.glob("*.md")):
            match = USE_CASE_RE.match(path.name)
            if match:
                key = (match.group(1), match.group(2))
                if key[0] in sequences:
                    self.error(path, f"duplicate use-case sequence {key[0]}; also used by {sequences[key[0]].name}")
                else:
                    sequences[key[0]] = path
                use_cases[key] = UseCase(path, *key)

        records: dict[tuple[str, str], Record] = {}
        implementation_dir = domain / "implementation"
        if implementation_dir.exists() and not implementation_dir.is_dir():
            self.error(implementation_dir, "implementation path is not a directory")
        for path in sorted(implementation_dir.glob("*.md")) if implementation_dir.is_dir() else []:
            match = USE_CASE_RE.match(path.name)
            if not match:
                self.error(path, "implementation record must be named NNN-<slug>.md")
                continue
            key = (match.group(1), match.group(2))
            if key in records:
                self.error(path, f"duplicate implementation pair {key[0]}-{key[1]}")
            records[key] = Record(path, *key)

        for key, use_case in use_cases.items():
            record = records.get(key)
            self.validate_use_case(use_case, record)
        for key, record in records.items():
            if key not in use_cases:
                self.error(record.path, f"orphan implementation record; no paired use case {key[0]}-{key[1]}")
            else:
                self.validate_record(record, use_cases[key])
        if domain_document.is_file():
            self.validate_domain_document(domain_document, {item.path for item in use_cases.values()})

    def validate_domain_document(self, path: Path, use_cases: set[Path]) -> None:
        lines = path.read_text(encoding="utf-8").splitlines()
        h2s = [(i + 1, line[3:].strip()) for i, line in enumerate(lines) if line.startswith("## ")]
        h2_names = [title for _, title in h2s]
        expected = ["Contents", "Boundary", "Requirements"]
        if h2_names != expected:
            self.error(path, "expected Contents, Boundary, and Requirements sections in canonical order")
            return

        contents_start = h2s[0][0]
        boundary_start = h2s[1][0]
        requirement_headings = [
            (i + 1, line[4:].strip())
            for i, line in enumerate(lines[h2s[2][0]:], h2s[2][0])
            if line.startswith("### ")
        ]
        contents_links = []
        for line_no in range(contents_start + 1, boundary_start):
            contents_links.extend(
                (line_no, match.group(1), match.group(2))
                for match in MARKDOWN_LINK_RE.finditer(lines[line_no - 1])
            )
        expected_labels = ["Boundary", "Requirements", *(title for _, title in requirement_headings)]
        actual_labels = [label for _, label, _ in contents_links]
        if actual_labels != expected_labels:
            self.error(path, "Contents must link Boundary, Requirements, and every requirement heading in order", contents_start)
        for line_no, _, target in contents_links:
            resolved, fragment = self.resolve_link_with_fragment(path, target)
            if resolved != path.resolve() or not fragment or not self.heading_exists(path, fragment):
                self.error(path, f"Contents link does not resolve to a local heading: {target}", line_no)

        entity_model_links = [
            target
            for _, target in self.iter_links(lines)
            if self.resolve_link(path, target) == path.parent / "entity-model.md"
        ]
        if len(entity_model_links) != 1:
            self.error(path, "expected exactly one Entity Model link")

        linked_use_cases: set[Path] = set()
        use_case_field_lines = {
            i for i, line in enumerate(lines, 1) if line.strip() == "**Use cases**"
        }
        owned_field_lines: set[int] = set()
        for index, (heading_line, _) in enumerate(requirement_headings):
            section_end = (
                requirement_headings[index + 1][0] - 1
                if index + 1 < len(requirement_headings)
                else len(lines)
            )
            fields = [
                line_no
                for line_no in range(heading_line + 1, section_end + 1)
                if lines[line_no - 1].strip() == "**Use cases**"
            ]
            owned_field_lines.update(fields)
            if len(fields) > 1:
                self.error(path, "a requirement may contain at most one Use cases field", fields[1])
            for field_line in fields:
                bullets = 0
                for line_no in range(field_line + 1, section_end + 1):
                    line = lines[line_no - 1]
                    if not line.strip():
                        continue
                    match = USE_CASE_BULLET_RE.fullmatch(line)
                    if not match:
                        self.error(path, "Use cases must contain one local use-case link per bullet", line_no)
                        continue
                    bullets += 1
                    resolved = self.resolve_link(path, match.group(1))
                    if resolved is not None and resolved.parent == path.parent and USE_CASE_RE.match(resolved.name):
                        linked_use_cases.add(resolved)
                if bullets == 0:
                    self.error(path, "Use cases requires at least one linked use case", field_line)
        for line_no in sorted(use_case_field_lines - owned_field_lines):
            self.error(path, "Use cases must appear within an owning requirement", line_no)
        for use_case in sorted(use_cases - linked_use_cases):
            self.error(path, f"use case is not linked by an owning requirement: {use_case.name}")

    def validate_use_case(self, use_case: UseCase, record: Record | None) -> None:
        lines = use_case.path.read_text(encoding="utf-8").splitlines()
        h1s = [(i + 1, line) for i, line in enumerate(lines) if line.startswith("# ")]
        if len(h1s) != 1:
            self.error(use_case.path, "expected exactly one H1 title")
        statuses = [(i + 1, STATUS_RE.match(line)) for i, line in enumerate(lines)]
        status_matches = [(line, match.group(1)) for line, match in statuses if match]
        if len(status_matches) != 1:
            self.error(use_case.path, "expected exactly one Status line")
        status = status_matches[0][1] if status_matches else None
        if len(h1s) == 1 and len(status_matches) == 1:
            first_content_after_h1 = next(
                (i + 1 for i, line in enumerate(lines[h1s[0][0]:], h1s[0][0]) if line.strip()),
                None,
            )
            if first_content_after_h1 != status_matches[0][0]:
                self.error(use_case.path, "Status must be the first non-empty line after the H1", status_matches[0][0])
        headings = [(i + 1, line[3:].strip()) for i, line in enumerate(lines) if line.startswith("## ")]
        heading_names = [title for _, title in headings]
        if heading_names == ["Approved Removal"]:
            if status != "Approved":
                self.error(use_case.path, "Approved Removal requires Approved status")
            for field in ("Interaction to remove", "Required observable absence", "Final verification"):
                count = sum(line.startswith(f"- **{field}:**") for line in lines)
                if count != 1:
                    self.error(use_case.path, f"Approved Removal requires exactly one {field} field")
            if any(line.startswith("### ") for line in lines):
                self.error(use_case.path, "Approved Removal allows no subsections")
            allowed_prefixes = tuple(
                f"- **{field}:**" for field in ("Interaction to remove", "Required observable absence", "Final verification")
            )
            structural_lines = {
                h1s[0][0] if len(h1s) == 1 else -1,
                status_matches[0][0] if len(status_matches) == 1 else -1,
                headings[0][0],
            }
            for line_no, line in enumerate(lines, 1):
                if not line.strip() or line_no in structural_lines or line.startswith(allowed_prefixes):
                    continue
                self.error(use_case.path, "Approved Removal contains unexpected content", line_no)
            return

        for section in REQUIRED_USE_CASE_SECTIONS:
            count = heading_names.count(section)
            if count != 1:
                self.error(use_case.path, f"expected exactly one {section} section")
        expected_headings = list(REQUIRED_USE_CASE_SECTIONS)
        allowed_headings = [expected_headings]
        if status in {"Draft", "Review"}:
            allowed_headings.append([*expected_headings, "Open Questions"])
        if heading_names not in allowed_headings:
            self.error(use_case.path, "unexpected or misplaced use-case section")
        positions = [heading_names.index(section) for section in REQUIRED_USE_CASE_SECTIONS if section in heading_names]
        if len(positions) == len(REQUIRED_USE_CASE_SECTIONS) and positions != sorted(positions):
            self.error(use_case.path, "use-case sections are not in canonical order")
        diagram_start = next((line for line, title in headings if title == "Behavior Diagrams"), None)
        flow_start = next((line for line, title in headings if title == "Flow"), None)
        if diagram_start and flow_start:
            diagram_lines = lines[diagram_start:flow_start - 1]
            subsections = [line[4:].strip() for line in diagram_lines if line.startswith("### ")]
            if not subsections or subsections[0] != "Overview" or subsections.count("Overview") != 1:
                self.error(use_case.path, "Behavior Diagrams requires exactly one leading Overview", diagram_start)
            if len(subsections) > 4:
                self.error(use_case.path, "Behavior Diagrams allows at most three named process diagrams", diagram_start)
            subsection_starts = [i for i, line in enumerate(diagram_lines) if line.startswith("### ")]
            for index, start in enumerate(subsection_starts):
                end = subsection_starts[index + 1] if index + 1 < len(subsection_starts) else len(diagram_lines)
                if sum(line.strip() == "```mermaid" for line in diagram_lines[start:end]) != 1:
                    self.error(use_case.path, f"diagram subsection {subsections[index]} requires exactly one Mermaid block", diagram_start + start)

    def validate_record(self, record: Record, use_case: UseCase) -> None:
        record_errors_before = len(self.errors)
        lines = record.path.read_text(encoding="utf-8").splitlines()
        h1s = [(i + 1, line) for i, line in enumerate(lines) if line.startswith("# ")]
        if len(h1s) != 1:
            self.error(record.path, "expected exactly one H1 title")
        backlinks = [(i + 1, USE_CASE_LINK_RE.match(line)) for i, line in enumerate(lines)]
        matches = [(line, match.group(1)) for line, match in backlinks if match]
        if len(matches) != 1:
            self.error(record.path, "expected exactly one Use Case backlink")
        elif self.resolve_link(record.path, matches[0][1]) != use_case.path:
            self.error(record.path, "Use Case backlink does not resolve to paired use case", matches[0][0])

        h2s = [(i + 1, line[3:].strip()) for i, line in enumerate(lines) if line.startswith("## ")]
        h3s = [(i + 1, line[4:].strip()) for i, line in enumerate(lines) if line.startswith("### ")]
        if [title for _, title in h2s] != ["Implementation"]:
            self.error(record.path, "expected exactly one Implementation section")
        if [title for _, title in h3s] != ["Locations", "Verification"]:
            self.error(record.path, "expected Locations and Verification subsections in canonical order")

        entries = [(i + 1, ENTRY_RE.match(line)) for i, line in enumerate(lines)]
        entry_matches = [(line, match.group(1)) for line, match in entries if match]
        if len(entry_matches) != 1:
            self.error(record.path, "expected exactly one non-empty Entry field")

        locations_start = next((line for line, title in h3s if title == "Locations"), None)
        verification_start = next((line for line, title in h3s if title == "Verification"), None)
        implementation_start = next((line for line, title in h2s if title == "Implementation"), None)
        if (len(matches) == 1 and implementation_start is not None and
                not (matches[0][0] < implementation_start)):
            self.error(record.path, "Use Case backlink must precede the Implementation section", matches[0][0])
        if (len(entry_matches) == 1 and implementation_start is not None and locations_start is not None and
                not (implementation_start < entry_matches[0][0] < locations_start)):
            self.error(record.path, "Entry must appear inside Implementation before Locations", entry_matches[0][0])
        location_links = []
        if locations_start and verification_start and locations_start < verification_start:
            for line_no in range(locations_start + 1, verification_start):
                location_links.extend((line_no, match.group(2)) for match in MARKDOWN_LINK_RE.finditer(lines[line_no - 1]))
        if not location_links:
            self.error(record.path, "Locations requires at least one Markdown file link", locations_start)
        for line_no, target in location_links:
            resolved = self.resolve_link(record.path, target)
            if resolved is None or not resolved.is_file():
                self.error(record.path, f"Locations link does not resolve: {target}", line_no)

        missing_proof = False
        if verification_start:
            verification_lines = lines[verification_start:]
            if not any(line.strip().startswith("-") for line in verification_lines):
                self.error(record.path, "Verification requires at least one bullet", verification_start)
            missing_proof = any(line.lstrip("- ").startswith("Missing") for line in verification_lines)

        status = self.status(use_case.path)
        if status == "Implemented":
            if len(self.errors) > record_errors_before:
                self.error(use_case.path, "Implemented requires a structurally valid implementation record")
            if missing_proof:
                self.error(use_case.path, "Implemented cannot have a Missing verification gap")

    @staticmethod
    def status(path: Path) -> str | None:
        for line in path.read_text(encoding="utf-8").splitlines():
            match = STATUS_RE.match(line)
            if match:
                return match.group(1)
        return None

    @staticmethod
    def iter_links(lines: list[str]):
        for i, line in enumerate(lines, 1):
            for match in MARKDOWN_LINK_RE.finditer(line):
                yield i, match.group(2)

    def validate_local_links(self, path: Path) -> None:
        lines = path.read_text(encoding="utf-8").splitlines()
        for line_no, target in self.iter_links(lines):
            parsed = urlsplit(unquote(target))
            if parsed.scheme or parsed.netloc:
                continue
            resolved, fragment = self.resolve_link_with_fragment(path, target)
            if resolved is None:
                self.error(path, f"link does not resolve: {target}", line_no)
            elif fragment and not self.heading_exists(resolved, fragment):
                self.error(path, f"fragment does not resolve: {target}", line_no)

    def resolve_link(self, source: Path, target: str) -> Path | None:
        return self.resolve_link_with_fragment(source, target)[0]

    def resolve_link_with_fragment(self, source: Path, target: str) -> tuple[Path | None, str | None]:
        parsed = urlsplit(unquote(target))
        if parsed.scheme or parsed.netloc:
            return None, parsed.fragment or None
        candidate = (source.parent / parsed.path).resolve() if parsed.path else source.resolve()
        try:
            candidate.relative_to(self.repo_root.resolve())
        except ValueError:
            return None, parsed.fragment or None
        return (candidate if candidate.exists() else None), (parsed.fragment or None)

    @staticmethod
    def heading_exists(path: Path, fragment: str) -> bool:
        slug = re.sub(r"[^a-z0-9 -]", "", fragment.lower()).replace(" ", "-")
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.startswith("#"):
                title = re.sub(r"[^a-z0-9 -]", "", line.lstrip("#").strip().lower()).replace(" ", "-")
                if title == slug:
                    return True
        return False


def normalize(path: Path) -> tuple[Path, str | None]:
    path = path.resolve()
    if path.is_file():
        if path.parent.name == "implementation":
            if (not USE_CASE_RE.match(path.name) or path.parent.parent.parent.name != "spec"
                    or path.parent.parent.parent.parent.name != "docs"):
                raise ValueError("path must be docs/spec, a domain directory, or a use-case/implementation file")
            return path.parent.parent.parent, path.parent.parent.name
        if (not USE_CASE_RE.match(path.name) or path.parent.parent.name != "spec"
                or path.parent.parent.parent.name != "docs"):
            raise ValueError("path must be docs/spec, a domain directory, or a use-case/implementation file")
        return path.parent.parent, path.parent.name
    if path.name == "spec" and path.parent.name == "docs":
        return path, None
    if path.parent.name == "spec" and path.parent.parent.name == "docs" and path.is_dir():
        return path.parent, path.name
    raise ValueError("path must be docs/spec, a domain directory, or a use-case/implementation file")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path, help="docs/spec, a domain directory, or a use-case/implementation file")
    parser.add_argument("--repo-root", type=Path, help="repository root used to resolve Locations links")
    args = parser.parse_args(argv)
    try:
        spec_root, domain_name = normalize(args.path)
    except ValueError as exc:
        parser.error(str(exc))
    if args.repo_root:
        repo_root = args.repo_root.resolve()
    elif domain_name is None:
        repo_root = spec_root.parent.parent.resolve()
    else:
        repo_root = spec_root.parent.parent.resolve()
    validator = Validation(repo_root, spec_root)
    validator.run(domain_name)
    if validator.errors:
        print("\n".join(validator.errors), file=sys.stderr)
        return 1
    scope = "all domains" if domain_name is None else f"domain {domain_name}"
    print(f"scope: {scope}")
    print("validated foundation, navigation, use cases, local links, and optional implementation records")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
