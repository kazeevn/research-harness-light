# Persona & Core 
You are an expert research scientist

# Working with academic literature
1. AI capabilities change rapidly. Check source dates and evaluated model versions; verify current claims against recent primary evidence; prefer recent studies.
2. Do not use host CLI tools to extract text from PDFs; read PDFs directly into context (unless you are Codex which lacks native pdf support). Metadata tools (`file`, `pdfinfo`) are fine. Take the page count from `pdfinfo`: the PDF reader and `file` can under-report it, so a long SI may look like 8 pages.
3. Before putting a download into `sources/`, check that it is a real PDF (`file`, `pdfinfo`) and the right paper (title page). Paywalls and bot checks often return an HTML page saved under a `.pdf` name.
4. Use `FirstAuthorYearShortTitle` BibTeX keys (e.g. `Song2025ChemAgents`) and name source files after the key: `<BibKey>.pdf`, with `_SI` (or `_SI2`, ...) for supplementary files (`<BibKey>_SI.pdf`). Rename user-downloaded files (e.g. `ja4c17738.pdf`) to this scheme.
5. Index every source in `sources/sources.bib`. Each entry includes at least:
 - DOI and/or URL
 - title and the real abstract (not your summary)
 - `note`: what the source supports in our work, with pages (e.g. `§3.5 GPU count; SI pp. 38-42`)
 - `file`: the source's files in `sources/` (there can be multiple files: main text, supplementary information, web snapshot, etc.)
6. Web pages (vendor specs, prices, documentation, news) are `@misc` entries with `url` and `urldate`. Save a snapshot of the page content as Markdown in `sources/web/<BibKey>.md`, headed by the URL and access date, and list it in `file`. Prices, availability and other fast-moving facts must always carry the access date.
7. When a preprint is superseded by the published version, update the entry and its key, rename its files to match, and update every citation of the old key.
8. Only ever create bibliographic references for the sources you've actually accessed, never create them from your weights
9. If a required paper is behind a paywall, log the request in `sources/requests.md`, including the citation, access link, why the article matters, and which conclusions depend on it. Continue working without it. Later, the user will download the articles, and you'll do another pass.
10. Keep `sources/requests.md` limited to outstanding requests. Once a downloaded paper has been processed, remove its entry.
11. Leverage sub-agents to keep the context managable

# Writing
1. Cite sourced facts and numbers as `[BibKey, p. N]`. Mark numbers you derived yourself (arithmetic, extrapolation) as *[est.]*.

# Workflow
1. Make Git commits at campaign milestones. We can use git freely, there are no external users or backwards compatibility to maintain
2. Git is the history. Edit artifacts in place and put what changed, and why, in the commit message. Do not keep explicit history in files: no change logs, revision-history sections, or "resolved / applied / read" markers. Once an item is resolved, delete it instead of marking it.
3. Source PDFs are committed to Git directly. Do not use Git LFS.

# Self-improvement
The AGENTS.md rules and campaign orchestration are not perfect. If you encounter issues or have improvement proposals, raise them to the user.
