# Dennis Kim — Resume

[![Built with Pandoc](https://img.shields.io/badge/built%20with-pandoc-blueviolet)](https://pandoc.org/)
[![LaTeX](https://img.shields.io/badge/engine-lualatex%20|%20xelatex%20|%20tectonic-green)](https://www.latex-project.org/)

Programmatic resume source in Markdown, built to PDF/DOCX/HTML via [Pandoc](https://pandoc.org/) with the [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) LaTeX template.

**2 pages** · Source Sans 3 · Source Code Pro · Clean, modern aesthetic with accent bars under section headings.

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
| [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3) | ✅ | Primary font for PDF output |
| [Source Code Pro](https://fonts.google.com/specimen/Source+Code+Pro) | ✅ | Monospace font for code |
| `Eisvogel` template | ✅ | LaTeX template for PDF layout |

Install on Fedora / RHEL:

```bash
sudo dnf install pandoc texlive-scheme-medium texlive-luatex
# Install fonts:
sudo dnf install adobe-source-sans-pro-fonts adobe-source-code-pro-fonts
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
├── resume-preamble.tex       # LaTeX header tweaks (accent bars, spacing)
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

Edit `resume.md` and rebuild. The YAML frontmatter controls metadata and layout:

```yaml
---
title: "Dennis Kim — AI-enabled Product Builder & Development Team Lead"
author: "Dennis Kim"
geometry: "left=0.7in,right=0.7in,top=0.5in,bottom=0.5in"
fontsize: 10pt
mainfont: Source Sans 3
monofont: Source Code Pro
linkcolor: darkgray
disable-header-and-footer: true
---
```

For visual styling (accent bars under section headings, compact spacing), edit `resume-preamble.tex`.

## Technical Details

- **Font**: Source Sans 3 at 10pt for body, Source Code Pro for monospace
- **Layout**: 0.7in side margins, 0.5in top/bottom — optimized for 2-page fit
- **Headings**: Dark gray accent color with thin rule underneath each section heading
- **Links**: Dark gray (not blue) for a more sophisticated look
- **Header/footer**: Disabled for clean pages
- **PDF engine**: LuaLaTeX (auto-detected, falls back to XeLaTeX or Tectonic)
- **Template**: Eisvogel 3.3.0 with custom preamble via `--include-in-header`

## Key Content Decisions

- **Title**: "AI-enabled Product Builder & Development Team Lead" — distinctively positions as a builder who uses AI, not a traditional PM
- **MarketAxess**: Shown as career progression (BA → PO → PM) with dates, not a single role
- **AI bullets**: Two concrete AI-assisted development examples (web platform + CLI tool) to back up the "AI-enabled" claim
- **C-suite cuts**: Removed tactical/weak bullets (Tradability, multi-vendor integrations, production accountability, "Jira program lead", Rising Star nomination, BuyandHold.com, license numbers)
- **Page count**: Aggressively trimmed to fit 2 pages (10pt, tight margins, compact spacing)

## License

The content of this resume is personal information. The build scripts and tooling are available as reference under MIT (if applicable).
