import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


VALIDATOR = Path(__file__).parents[1] / "scripts" / "validate_spec.py"


USE_CASE = """\
# Example

**Status:** {status}

## Goal

One observable goal.

## Actors

- **Primary:** User

## Preconditions

- The user is authorized.

## Trigger

The user requests the result.

## Behavior Diagrams

### Overview

```mermaid
flowchart TD
    A[Request result] --> B[Return result]
```

## Flow

1. The system returns the result.

## Postconditions

### On Success

- The result is available.

### On Failure

- Existing state is unchanged.
"""


RECORD = """\
# Example

**Use Case:** [Example](../001-example.md)

## Implementation

The current path returns the requested result.

**Entry:** Public request

### Locations

- [source.py](../../../../source.py) — request handling

### Verification

- {verification}
"""


APPROVED_REMOVAL = """\
# Example

**Status:** Approved

## Approved Removal

- **Interaction to remove:** The user can request the result.
- **Required observable absence:** The result is no longer available.
- **Final verification:** The request is rejected without changing state.
"""


DOMAIN = """\
# Demo

Demo behavior.

**Entity Model:** [Demo Entity Model](entity-model.md)

## Contents

- [Boundary](#boundary)
- [Requirements](#requirements)
  - [Example Requirement](#example-requirement)

## Boundary

- **Owns:** Demo behavior.
- **Excludes:** Other behavior.

## Requirements

### Example Requirement

**Capabilities**

- A user can request a result.
"""

DOMAIN_WITH_USE_CASE = DOMAIN + """\

**Use cases**

- [001 — Example](001-example.md)
"""

CATALOG = """\
# Product Specifications

## Domains

### [Demo](demo/domain.md)

Demo behavior.
"""


class ValidatorTests(unittest.TestCase):
    def run_validator(
        self,
        files: dict[str, str],
        include_foundation: bool = True,
        validation_path: str = "docs/spec",
    ) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            inputs = ({
                "docs/spec/catalog.md": CATALOG,
                "docs/spec/demo/domain.md": DOMAIN_WITH_USE_CASE,
                "docs/spec/demo/entity-model.md": "# Demo Entity Model\n",
            } if include_foundation else {})
            inputs.update(files)
            for relative, content in inputs.items():
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(textwrap.dedent(content), encoding="utf-8")
            return subprocess.run(
                [sys.executable, str(VALIDATOR), str(root / validation_path), "--repo-root", str(root)],
                text=True,
                capture_output=True,
                check=False,
            )

    def test_implemented_use_case_does_not_require_record(self) -> None:
        result = self.run_validator({"docs/spec/demo/001-example.md": USE_CASE.format(status="Implemented")})
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_domain_contents_is_valid(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/domain.md": DOMAIN,
            "docs/spec/demo/entity-model.md": "# Demo Entity Model\n",
        })
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_domain_contents_requires_every_requirement_in_order(self) -> None:
        invalid = DOMAIN.replace("  - [Example Requirement](#example-requirement)\n", "")
        result = self.run_validator({
            "docs/spec/demo/domain.md": invalid,
            "docs/spec/demo/entity-model.md": "# Demo Entity Model\n",
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Contents must link Boundary, Requirements, and every requirement heading in order", result.stderr)

    def test_domain_foundation_is_required(self) -> None:
        result = self.run_validator({
            "docs/spec/catalog.md": "# Product Specifications\n",
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
        }, include_foundation=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing domain document", result.stderr)
        self.assertIn("missing Entity Model", result.stderr)

    def test_root_catalog_is_required(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/domain.md": DOMAIN,
            "docs/spec/demo/entity-model.md": "# Demo Entity Model\n",
        }, include_foundation=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing root catalog", result.stderr)

    def test_domain_scope_does_not_validate_unrelated_domain_links(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/domain.md": DOMAIN,
            "docs/spec/other/domain.md": "# Other\n\n[Broken](missing.md)\n",
        }, validation_path="docs/spec/demo")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_use_case_requires_owning_requirement_link(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/domain.md": DOMAIN,
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("use case is not linked by an owning requirement", result.stderr)

    def test_use_case_link_outside_requirement_is_rejected(self) -> None:
        invalid = DOMAIN.replace(
            "## Requirements",
            "**Use cases**\n\n- [001 — Example](001-example.md)\n\n## Requirements",
        )
        result = self.run_validator({
            "docs/spec/demo/domain.md": invalid,
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Use cases must appear within an owning requirement", result.stderr)

    def test_use_case_field_requires_one_link_per_bullet(self) -> None:
        invalid = DOMAIN_WITH_USE_CASE.replace(
            "- [001 — Example](001-example.md)",
            "- Example: [001 — Example](001-example.md)",
        )
        result = self.run_validator({
            "docs/spec/demo/domain.md": invalid,
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Use cases must contain one local use-case link per bullet", result.stderr)

    def test_duplicate_sequence_is_rejected(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
            "docs/spec/demo/001-other.md": USE_CASE.format(status="Approved"),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("duplicate use-case sequence 001", result.stderr)

    def test_canonical_sections_are_required(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/001-example.md": "# Example\n\n**Status:** Approved\n",
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expected exactly one Goal section", result.stderr)

    def test_status_must_follow_h1(self) -> None:
        invalid = USE_CASE.format(status="Approved").replace("**Status:** Approved\n\n", "")
        invalid += "\n**Status:** Approved\n"
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Status must be the first non-empty line after the H1", result.stderr)

    def test_approved_removal_is_valid(self) -> None:
        result = self.run_validator({"docs/spec/demo/001-example.md": APPROVED_REMOVAL})
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_approved_removal_rejects_extra_structure(self) -> None:
        invalid = APPROVED_REMOVAL + "\n### Notes\n\nUnexpected detail.\n"
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Approved Removal allows no subsections", result.stderr)
        self.assertIn("Approved Removal contains unexpected content", result.stderr)

    def test_draft_keeps_canonical_structure(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Draft") + "\n## Open Questions\n\n- Which result?\n",
        })
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_approved_rejects_open_questions(self) -> None:
        result = self.run_validator({
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved") + "\n## Open Questions\n\n- Which result?\n",
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unexpected or misplaced use-case section", result.stderr)

    def test_overview_subsection_is_required(self) -> None:
        invalid = USE_CASE.format(status="Approved").replace("### Overview", "### Process")
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires exactly one leading Overview", result.stderr)

    def test_duplicate_overview_is_rejected(self) -> None:
        duplicate = """\
### Overview

```mermaid
flowchart TD
    A[Request] --> B[Result]
```

"""
        invalid = USE_CASE.format(status="Approved").replace("## Flow", duplicate + "## Flow")
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires exactly one leading Overview", result.stderr)

    def test_more_than_three_process_diagrams_is_rejected(self) -> None:
        process_diagrams = "".join(
            f"### Process {index}\n\n```mermaid\nflowchart TD\n    A{index}[Start] --> B{index}[End]\n```\n\n"
            for index in range(1, 5)
        )
        invalid = USE_CASE.format(status="Approved").replace("## Flow", process_diagrams + "## Flow")
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("allows at most three named process diagrams", result.stderr)

    def test_each_diagram_subsection_requires_one_mermaid_block(self) -> None:
        extra = """\
```mermaid
flowchart TD
    C[Duplicate] --> D[Block]
```

"""
        invalid = USE_CASE.format(status="Approved").replace("## Flow", extra + "## Flow")
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires exactly one Mermaid block", result.stderr)

    def test_unresolved_local_link_is_rejected(self) -> None:
        invalid = USE_CASE.format(status="Approved").replace(
            "One observable goal.", "One [observable goal](missing.md)."
        )
        result = self.run_validator({"docs/spec/demo/001-example.md": invalid})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("link does not resolve: missing.md", result.stderr)

    def test_compact_record_is_valid(self) -> None:
        result = self.run_validator({
            "source.py": "pass\n",
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Implemented"),
            "docs/spec/demo/implementation/001-example.md": RECORD.format(verification="Behavioral proof exists."),
        })
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_record_rejects_extra_or_misordered_subsections(self) -> None:
        invalid = RECORD.format(verification="Behavioral proof exists.").replace(
            "### Locations", "### Notes\n\nExtra detail.\n\n### Locations"
        )
        result = self.run_validator({
            "source.py": "pass\n",
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
            "docs/spec/demo/implementation/001-example.md": invalid,
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expected Locations and Verification subsections in canonical order", result.stderr)

    def test_record_requires_one_h1(self) -> None:
        invalid = RECORD.format(verification="Behavioral proof exists.").replace("# Example\n\n", "")
        result = self.run_validator({
            "source.py": "pass\n",
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Approved"),
            "docs/spec/demo/implementation/001-example.md": invalid,
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expected exactly one H1 title", result.stderr)

    def test_missing_verification_blocks_implemented(self) -> None:
        result = self.run_validator({
            "source.py": "pass\n",
            "docs/spec/demo/001-example.md": USE_CASE.format(status="Implemented"),
            "docs/spec/demo/implementation/001-example.md": RECORD.format(verification="Missing — focused proof."),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Implemented cannot have a Missing verification gap", result.stderr)


if __name__ == "__main__":
    unittest.main()
