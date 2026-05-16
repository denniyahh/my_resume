# Dennis Kim — Resume

[![Built with Pandoc](https://img.shields.io/badge/built%20with-pandoc-blueviolet)](https://pandoc.org/)
[![LaTeX](https://img.shields.io/badge/engine-lualatex%20|%20xelatex%20|%20tectonic-green)](https://www.latex-project.org/)

Programmatic resume source in Markdown, built to PDF/DOCX/HTML via [Pandoc](https://pandoc.org/) with the [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) LaTeX template.

## Quick Start

```bash
# Build all output formats
./build_resume.sh

# Build outputs are written to dist/
ls dist/            # resume.pdf  resume.docx  resume.html
```

### Dependencies

| Tool | Required | Notes |
|---|---|---|
| `pandoc` | ✅ | Document conversion |
| `lualatex` / `xelatex` / `tectonic` | ✅ | PDF engine (auto-detected) |
| [Inter font](https://rsms.me/inter/) | Recommended | Primary font for PDF output |
| `Eisvogel` template | Recommended | Installed via the bundled `Eisvogel-3.3.0/` dir |

Install on Fedora / RHEL:

```bash
sudo dnf install pandoc texlive-scheme-medium texlive-luatex
```

### Advanced Usage

The build script supports several environment variables:

```bash
# Use custom input file
./build_resume.sh path/to/custom.md

# Override output directory
OUT_DIR=output ./build_resume.sh

# Override base filename
BASENAME=dennis-kim-resume ./build_resume.sh

# Force a specific PDF engine
PDF_ENGINE=xelatex ./build_resume.sh

# Disable ATS-safe normalization (on by default)
ATS_SAFE=0 ./build_resume.sh

# Keep the normalized temp markdown for inspection
KEEP_TMP=1 ./build_resume.sh

# Use a different Pandoc template
PANDOC_TEMPLATE=eisvogel ./build_resume.sh
```

### ATS Safety

By default (`ATS_SAFE=1`), the PDF is built from a normalized copy where typographic characters (en/em dashes, middle dots, non-breaking spaces) are replaced with plain ASCII equivalents. This prevents text-extraction artifacts that can confuse applicant tracking systems.

## Project Structure

```
.
├── resume.md                 # Source of truth — Markdown + YAML frontmatter
├── build_resume.sh           # Build script (Pandoc pipeline)
├── templates/
│   └── eisvogel.latex        # Eisvogel Pandoc template
├── archive/
│   └── build_resume.sh       # Original build script (preserved)
├── dist/                     # Build output (gitignored)
│   └── .gitkeep
├── README.md
└── .gitignore
```

## Editing

Edit `resume.md` and rebuild. The YAML frontmatter controls metadata:

```yaml
---
title: "Dennis Kim — Resume"
author: "Dennis Kim"
geometry: margin=1in
fontsize: 11pt
mainfont: Inter
monofont: Liberation Mono
linkcolor: blue
---
```

## License

The content of this resume is personal information. The build scripts and tooling are available as reference under MIT (if applicable).
